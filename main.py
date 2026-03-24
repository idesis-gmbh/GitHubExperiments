import sys
import etl
import sd


if __name__ == "__main__":
    schema_discovery = len(sys.argv) > 1 and sys.argv[1] == "--sd"
    if schema_discovery:
        etl.run(prepare_schema_discovery=True)
        sd.run()
    else:
        etl.run()
