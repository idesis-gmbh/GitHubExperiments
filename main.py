import sys
import etl
import sd


if __name__ == "__main__":
    schema_discovery = len(sys.argv) > 1
    if schema_discovery and sys.argv[1] == "--infer-schema":
        if not etl.run_files(prepare_schema_discovery=True):
            sd.generate_model()
            etl.run_files()
    elif schema_discovery and sys.argv[1] == "--canonical-sample":
        if not etl.run_files(prepare_schema_discovery=True):
            sd.generate_canonical_sample("canonical_sample.json")
    elif schema_discovery and sys.argv[1] == "--canonical-schema":
        if not etl.run_file("canonical_sample.json", prepare_schema_discovery=True):
            sd.generate_model()
            etl.run_file("canonical_sample.json")
    else:
        etl.run_files()
