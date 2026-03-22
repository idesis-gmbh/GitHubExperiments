import duckdb
import sd


def main():
    with duckdb.connect("dev.duckdb") as connection:
        schema = sd.introspect_schema(connection)
        sd.generate_model(schema)


if __name__ == "__main__":
    main()
