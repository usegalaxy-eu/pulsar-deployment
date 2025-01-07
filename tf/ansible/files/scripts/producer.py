"""This script is a producer that publishes condor status details to the queue"""

import argparse
import os
import re
import subprocess
import sys
import time
import yaml
from kombu import Connection, Exchange, Producer, Queue


def get_amqp_url(pulsar_app_file: str) -> None:
    """
    Parse the Pulsar app.yml file and extract the AMQP URL.
    """
    # Check the existence of the job_conf.yml file
    if not os.path.exists(pulsar_app_file):
        print(f"File {pulsar_app_file} does not exist.")
        return None

    with open(pulsar_app_file, "r") as file:
        app_conf = yaml.safe_load(file)
        amqp_url = app_conf['message_queue_url']

    return amqp_url


def get_vhost_name(amqp_url: str) -> str:
    """
    Parse the AMQP URL to extract the vhost name.
    """
    vhost = amqp_url.split("/")[-1].split("?")[0]
    return vhost


def connect_to_queue(amqp_url: str) -> Connection:
    """
    Connect to the AMQP queue using the provided URL.
    """
    # With try and except block, connect to the AMQP queue using the provided URL and manage the error if the connection fails
    try:
        connection = Connection(amqp_url)
        connection.ensure_connection(max_retries=3)
        return connection
    except Exception as e:
        print(f"Error connecting to the AMQP queue: {e}")
        return None


def process_condor_status_output(condor_status_output: str) -> str:
    """
    Replace empty/None values  with 0 in the condor status output
    """
    processed_output = re.sub(r'(\w+)=,', r'\1=0,', condor_status_output)
    return processed_output


def get_condor_status(cluster_status_script_file: str) -> str:
    """
    Get condor status from shell script output
    """
    condor_metrics = process_condor_status_output(subprocess.check_output(["sh", cluster_status_script_file]).decode("utf-8").strip())

    # Add timestamp
    now = time.time()
    condor_metrics = f"{condor_metrics},querytime={now}"
    return condor_metrics


def produce_message(amqp_url: str, condor_metrics: str) -> None:
    """
    Produce and publish messages to the queue.
    """
    connection = connect_to_queue(amqp_url)

    if connection:
        vhost = get_vhost_name(amqp_url)
        routing_key = f"{vhost}-condor"
        channel = connection.channel()
        exchange = Exchange(f"{vhost}-condor-exchange", type="direct")
        producer = Producer(exchange=exchange, channel=channel, routing_key=routing_key)
        queue = Queue(name=f"{vhost}-condor-stats", exchange=exchange, routing_key=routing_key)
        queue.maybe_bind(connection)
        queue.declare()

        # Add destination to metrics
        condor_metrics = f"{condor_metrics},destinationd_id={vhost}"

        producer.publish(
            {"condor_metrics": condor_metrics},
            exchange=exchange,
            routing_key=routing_key,
            declare=[queue],
            serializer="json"
        )
        connection.release()


def main(pulsar_app_file: str, cluster_status_script_file: str) -> None:

    amqp_url = get_amqp_url(pulsar_app_file)

    if not amqp_url:
        print("No Pulsar url found in the pulsar configuration file.")
        sys.exit(1)

    # Get the condor status
    condor_metrics = get_condor_status(cluster_status_script_file)

    # Create and publish message
    produce_message(amqp_url, condor_metrics)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Produce messages to AMQP queues.")
    parser.add_argument("pulsar_app_file", type=str, help="Path to the Pulsar app configuration file (YAML).")
    parser.add_argument("cluster_status_script_file", type=str, help="Path to the shell script that produces influx compatible condor status metrics.")
    args = parser.parse_args()

    main(args.pulsar_app_file, args.cluster_status_script_file)

