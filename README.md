# tmpnb runtime and Jupyter Notebooks for NCSU Geospatial Modeling and Analysis course

## Prepare GRASS GIS image

Build it to have it locally:

```
docker build -t grass-gis-notebook github.com/wenzeslaus/geospatial-modeling-course-jupyter
```

In case you plan to modify the code, first download it and then build it:

```
docker build -t grass-gis-notebook .
```

Run it to test it:

```
docker run -it --rm -p 8888:8888 grass-gis-notebook
```

## Run tmpnb

Generate tokens:

```
export TOKEN=$( head -c 30 /dev/urandom | xxd -p )
export USER_TOKEN=$( head -c 30 /dev/urandom | xxd -p )
echo $USER_TOKEN
```

Run the proxy:

```
docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=proxy \
    jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999
```

Run tmpnb:

```
docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=tmpnb \
    -v /var/run/docker.sock:/docker.sock jupyter/tmpnb \
    python orchestrate.py --log-to-stderr --logging=debug \
    --use-tokens=False --image='grass-gis-notebook' \
    --command="start-notebook.sh \"--NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port} --NotebookApp.trust_xheaders=True --NotebookApp.token=$USER_TOKEN\""
```

## Generate the notebooks from HTML

```
for F in .../geospatial-modeling-course/grass/*.html;
do
    python .../geospatial-modeling-course/doc2nb.py \
        --grass grass \
        --gisdbase "/home/jovyan/grassdata" \
        --location "nc_spm_08_grass7" --mapset "user1"\
        $F `basename -s .html $F`.ipynb;
done;
```
