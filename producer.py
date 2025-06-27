from kafka import KafkaProducer


def main() -> None:
    producer = KafkaProducer(
        bootstrap_servers=["localhost:9092"],
        security_protocol="SASL_SSL",
        sasl_mechanism="PLAIN",
        sasl_plain_username="user",
        sasl_plain_password="bitnami123",
        ssl_cafile="/Users/patrykolejniczakorlowski/Development/Test/certs/ca.crt",
        ssl_check_hostname=False,
        value_serializer=lambda v: v.encode("utf-8"),
    )

    topic = "test"
    message = "hello from python producer"
    future = producer.send(topic, message)
    result = future.get(timeout=10)
    print(f"Successfully sent to {result.topic}:{result.partition} offset {result.offset}")
    producer.flush()


if __name__ == "__main__":
    main() 