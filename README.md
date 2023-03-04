# LoRA_Easy_Training_Scripts in Docker

- <https://github.com/derrian-distro/LoRA_Easy_Training_Scripts>
- <https://economylife.net/kohya-lora-install-use/>

## Environments

- Ubuntu 20.04 or later
- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) 23.0 or later
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Usage
### 1. Build Docker image

```shell
docker build . -t aoirint/lora_ets
```

### 2. Prepare Base Models

```shell
mkdir base_model
cd base_model
```

#### Anything v4.5

- <https://huggingface.co/andite/anything-v4.0>

```shell
wget https://huggingface.co/andite/anything-v4.0/resolve/main/anything-v4.5.ckpt
echo 'fbcf965a62d9d82e935d3d17e97522c29f44550aa9e120a6886f19b578521ec5  anything-v4.5.ckpt' | sha256sum -c -
```

#### Anything v4.0

- <https://huggingface.co/andite/anything-v4.0>

```shell
wget https://huggingface.co/andite/anything-v4.0/resolve/main/anything-v4.0.ckpt
echo '3b26c9c497c923a07ab8d55f2921cf44749535e4b0c890c5c37968e4c90e7258  anything-v4.0.ckpt' | sha256sum -c -

wget https://huggingface.co/andite/anything-v4.0/resolve/main/anything-v4.0.vae.pt
echo 'f921fb3f29891d2a77a6571e56b8b5052420d2884129517a333c60b1b4816cdf  anything-v4.0.vae.pt' | sha256sum -c -
```

<details>

#### ACertainThing

- <https://huggingface.co/JosephusCheung/ACertainThing>

```shell
wget https://huggingface.co/JosephusCheung/ACertainThing/resolve/main/ACertainThing.ckpt
echo '866946217b513157b12ff9b1eae2279e98ae34ece178e34eac536f2e831c101c  ACertainThing.ckpt' | sha256sum -c -
```

#### ACertainty

- <https://huggingface.co/JosephusCheung/ACertainty>

```shell
wget https://huggingface.co/JosephusCheung/ACertainty/resolve/main/ACertainty.ckpt
echo 'a64573359af0f1071ef01d0dc93df2bc90eb1d0bcf3e26058fbf5aeff37c6462  ACertainty.ckpt' | sha256sum -c -
```

</details>

### 2. Prepare Training Images

TBW

### 3. Prepare Regularization Images

TBW

### 4. Prepare JSON Config

- <https://github.com/derrian-distro/LoRA_Easy_Training_Scripts#list-of-arguments>

Create `work/20230225_001/config.json`.

```json
{
  "base_model": "/base_model/ACertainThing.ckpt",
  "img_folder": "/work/20230225_001/img",
  "reg_img_folder": "/work/20230225_001/reg_img",
  "output_folder": "/work/20230225_001/output",
  "num_epochs": 20,
  "batch_size": 1,
  "save_every_n_epochs": 1
}
```

### 5. Run Training

```shell
docker run --rm \
  --gpus all \
  -v "./base_model:/base_model" \
  -v "./work:/work" \
  -v "./cache/huggingface:/home/user/.cache/huggingface" \
  aoirint/lora_ets \
  --load_json_path=/work/20230225_001/config.json
```
