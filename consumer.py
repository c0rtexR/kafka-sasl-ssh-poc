from kafka import KafkaConsumer


def main() -> None:
    consumer = KafkaConsumer(
        "test",
        bootstrap_servers=["localhost:9092"],
        security_protocol="SASL_SSL",
        ssl_cafile="/Users/patrykolejniczakorlowski/Development/Test/certs/ca.crt",
        ssl_check_hostname=False,
        sasl_mechanism="PLAIN",
        sasl_plain_username="user",
        sasl_plain_password="bitnami123",
        auto_offset_reset="earliest",
        enable_auto_commit=False,
        value_deserializer=lambda v: v.decode("utf-8"),
    )

    print("Waiting for messages... (Ctrl+C to exit)")
    for message in consumer:
        print(f"Received: {message.value}")
        break  # Just read one for the PoC


if __name__ == "__main__":
    main() 