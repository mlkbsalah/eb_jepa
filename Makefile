CONTAINER_NAME = eb_jepa
PROJECT_DIR = ~/repos/eb_jepa

build-docker:
	docker build --platform linux/amd64 -t $(CONTAINER_NAME):latest .
	docker save $(CONTAINER_NAME):latest -o $(CONTAINER_NAME).tar

send:
	rsync -avz --progress $(CONTAINER_NAME).tar m-ben-salah@172.18.47.92:${PROJECT_DIR}/

build-and-send: build-docker send

build-apptainer:
	srun --job-name=build-apptainer \
	     --time=30:00 \
	     --mem=24G \
	     --cpus-per-task=4 \
	     --partition=ai \
	     apptainer build $(CONTAINER_NAME).sif docker-archive://$(CONTAINER_NAME).tar

run-interactive:
	srun --job-name=eb_jepa_interactive \
	     --time=30:00 \
	     --mem=24G \
	     --cpus-per-task=4 \
	     --partition=ai \
	     --gres=gpu:1 \
	     --pty apptainer shell --nv $(CONTAINER_NAME).sif