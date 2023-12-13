# Htsget-rs and sda-download

## Storage and interfaces
The storage and interfaces repository contains the pipeline that can be used to ingest files in the archive and therefore make them available for download using the sda-download service.
First copy the configuration files that the services need, by running:
```sh
cp config/config.yaml.example config/config.yaml
cp config/iss.json.example config/iss.json
cp .env.example .env
```
The docker compose contains a data loader, which will download the `htsnexus_test` files, ingest them and create a dataset for them. To start the docker compose, simply run:
```sh
docker compose -f docker-compose-demo.yml up
```
The `data loader` script will take some time to ingest the files. Once the script has exited you should be able to check that all four files are in the database, by running
```sh
docker exec -it postgres psql -h localhost -U postgres lega
```
with `rootpass` as password and in the container run the following sql query:
```sql
select stable_id, submission_file_path from sda.files;
```
You should see the four files with their stable id.

## htsget
To build a docker image run
```sh
docker build -f deploy/Dockerfile -t <image-name> .
```
and update the `image:` tag with the `<image-name>` in the docker-compose.yaml file, found in the [GDI htsget repository](https://github.com/GenomicDataInfrastructure/starter-kit-htsget/tree/feature/rust-htsget) (make sure to be in the `feature/rust-htsget` branch)

To start the htsget-rs server, run
```sh
docker compose up
```

### Get a file
To get a file from the htsget through sda-donwload, you first need to get a token from the mock-auth service using
```sh
token=': token=$(curl -s -k https://localhost:8080/tokens | jq -r '.[0]')
```
with this token, you can make a request to the htsget server. For example:
```sh
curl -v -H "Authorization: Bearer $token" -k http://localhost:8088/reads/EGAD74900000101/htsnexus_test_NA12878
```
This should return the JSON containing the URL to the sda-download, in order to get the file. To do that, run:
```sh
curl --location 'http://localhost:8443/s3/EGAD74900000101/htsnexus_test_NA12878.bam' --header "Authorization: Bearer $token" -o <some-file-name>
```

## Get a specific region
To get a region of a file, run the query towards the htsget:
```sh
curl -v -H "Authorization: Bearer $token" -k http://localhost:8088/reads/EGAD74900000101/htsnexus_test_NA12878?referenceName=2
```
and then use the byte range to get the file from the sda-download:
```sh
curl --location 'http://localhost:8443/s3/EGAD74900000101/htsnexus_test_NA12878.bam?startCoordinate=<STARTING-BYTE>&endCoordinate=<ENDING-BYTE>' --header "Authorization: Bearer $token"
```
Note that the sda-download is not returning always the correct ranges. That is a known bug, that will be fixed soon


## Troubleshooting
If the compose file for the storage and interfaces fails, try re-running it after removing all the volumes and orphan containers, using:
```sh
docker compose -f docker-compose-demo.yml down -v --remove-orphans
```

