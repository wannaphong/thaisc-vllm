# thaisc-vllm
Make vLLM working in ThaiSC LANTA

Build apptainer before upload to ThaiSC LANTA
```
docker run --privileged --rm \
  -v $(pwd):/work \
  -w /work \
  quay.io/singularity/singularity:v3.11.5 \
  build vllm.sif vllm.def
```

submit job:

> sbatch submit.sh
