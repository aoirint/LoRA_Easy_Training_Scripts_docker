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

#### Waifu Diffusion v1.4 Epoch 2

- <https://huggingface.co/hakurei/waifu-diffusion-v1-4>

```shell
wget 'https://huggingface.co/hakurei/waifu-diffusion-v1-4/resolve/main/wd-1-4-anime_e2.ckpt'
echo 'c76e0962bc60ccdc18e0dce387635b472b5a19038d637216030acbbe6eda2713  wd-1-4-anime_e2.ckpt' | sha256sum -c -

wget 'https://huggingface.co/hakurei/waifu-diffusion-v1-4/resolve/main/vae/kl-f8-anime2.ckpt'
echo 'df3c506e51b7ee1d7b5a6a2bb7142d47d488743c96aa778afb0f53a2cdc2d38d  kl-f8-anime2.ckpt' | sha256sum -c -
```

<details>

#### Waifu Diffusion v1.5 Beta 2

- <https://huggingface.co/waifu-diffusion/wd-1-5-beta2>

```shell
wget 'https://huggingface.co/waifu-diffusion/wd-1-5-beta2/resolve/main/checkpoints/wd-1-5-beta2-fp32.safetensors'
echo '764f93581d80b46011039bb388e899f17f7869fce7e7928b060e9a5574bd8f84  wd-1-5-beta2-fp32.safetensors' | sha256sum -c -
```

#### Waifu Diffusion v1.3

- <https://huggingface.co/hakurei/waifu-diffusion-v1-3>

```shell
wget 'https://huggingface.co/hakurei/waifu-diffusion-v1-3/resolve/main/wd-v1-3-full-opt.ckpt'
echo '10912b9a6d773ea7c299c0563d10538ada04ade81837362b6c0c67be4df937c1  wd-v1-3-full-opt.ckpt' | sha256sum -c -
```

#### Anything v5

- <https://civitai.com/models/9409?modelVersionId=29588>

```shell
echo '7f96a1a9ca9b3a3242a9ae95d19284f0d2da8d5282b42d2d974398bf7663a252  anything-v5-prt-re.safetensors' | sha256sum -c -
```

#### Anything v4.5

- <https://huggingface.co/andite/anything-v4.0>

```shell
wget 'https://huggingface.co/andite/anything-v4.0/resolve/main/anything-v4.5.ckpt'
echo 'fbcf965a62d9d82e935d3d17e97522c29f44550aa9e120a6886f19b578521ec5  anything-v4.5.ckpt' | sha256sum -c -
```

#### Anything v4.0

- <https://huggingface.co/andite/anything-v4.0>

```shell
wget 'https://huggingface.co/andite/anything-v4.0/resolve/main/anything-v4.0.ckpt'
echo '3b26c9c497c923a07ab8d55f2921cf44749535e4b0c890c5c37968e4c90e7258  anything-v4.0.ckpt' | sha256sum -c -

wget 'https://huggingface.co/andite/anything-v4.0/resolve/main/anything-v4.0.vae.pt'
echo 'f921fb3f29891d2a77a6571e56b8b5052420d2884129517a333c60b1b4816cdf  anything-v4.0.vae.pt' | sha256sum -c -
```

#### Anything v3

- <https://civitai.com/models/9409?modelVersionId=11162>

```shell
echo '8712e20a5d65b6acaa743e8a74961eadfdf846a2c9a32160d80a80cba13ad475  anything-v3.ckpt' | sha256sum -c -

echo 'f921fb3f29891d2a77a6571e56b8b5052420d2884129517a333c60b1b4816cdf  anything-v3.vae.pt' | sha256sum -c -

# VAE embbeded
echo 'abcaf14e5acb8023c79c3901f8ffc04eb3c646d7793f3b36a439bf09e32868cd  anything-v3-full.safetensors' | sha256sum -c -
```

#### ACertainThing

- <https://huggingface.co/JosephusCheung/ACertainThing>

```shell
wget 'https://huggingface.co/JosephusCheung/ACertainThing/resolve/main/ACertainThing.ckpt'
echo '866946217b513157b12ff9b1eae2279e98ae34ece178e34eac536f2e831c101c  ACertainThing.ckpt' | sha256sum -c -
```

#### ACertainty

- <https://huggingface.co/JosephusCheung/ACertainty>

```shell
wget 'https://huggingface.co/JosephusCheung/ACertainty/resolve/main/ACertainty.ckpt'
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
mkdir -p cache/huggingface/hub
chown -R 1000:1000 cache

docker run --rm \
  --gpus all \
  -v "./base_model:/base_model" \
  -v "./work:/work" \
  -v "./cache/huggingface/hub:/home/user/.cache/huggingface/hub" \
  aoirint/lora_ets \
  --load_json_path=/work/20230225_001/config.json
```
