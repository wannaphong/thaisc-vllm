#!/bin/bash
#SBATCH --job-name=vllm_test
#SBATCH -p gpu                           # Specify partition [Compute/Memory/GPU]
#SBATCH -N 1 -c 16                               # Specify number of nodes and processors per task
#SBATCH --gpus-per-node=4                        # Specify number of GPU per task
#SBATCH --ntasks-per-node=4                      # Specify tasks per node
#SBATCH -t 2:00:00                     # Specify maximum time limit (hour: minute: second)
#SBATCH -A ltXXX # your ID        
#SBATCH --error=log.out.%j
#SBATCH --output=log.out.%j
module load Apptainer/1.1.6

LOCAL_MODEL_PATH="/project/xxx/models/gemma-3-27b-it"

echo "Starting vLLM server inside Apptainer..."

# 1. Start vLLM using the CUDA 11.8 container
apptainer exec --nv \
  --bind $LOCAL_MODEL_PATH:/local_model \
  ../vllm.sif \
  python3 -m vllm.entrypoints.openai.api_server \
  --model /local_model \
  --served-model-name "google/gemma-3-27b-it" \
  --dtype auto \
  --tensor-parallel-size 4 \
  --max-model-len 32768 \
  --max-num-seqs 16 \
  --port 8000 &
VLLM_PID=$!

echo "Waiting for vLLM to initialize..."
while ! curl -s http://localhost:8000/v1/models > /dev/null; do
    sleep 10
done
echo "vLLM server is online!"

# 2. Run the Python Script directly (No pip install needed anymore!)
echo "Executing Evaluation Script..."
apptainer exec \
  --bind $PWD:/workspace \
  --pwd /workspace \
  ../vllm.sif \
  python3 main.py

echo "Evaluation complete. Shutting down vLLM server."
kill $VLLM_PID
