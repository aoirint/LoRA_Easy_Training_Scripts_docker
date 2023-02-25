# LoRA_Easy_Training_Scripts in Docker

- <https://github.com/derrian-distro/LoRA_Easy_Training_Scripts>
- <https://economylife.net/kohya-lora-install-use/>

## Build

```shell
docker build . -t lets
```

## Base Models

```shell
mkdir base_model
cd base_model
```

### ACertainThing

- <https://huggingface.co/JosephusCheung/ACertainThing>

```shell
wget https://huggingface.co/JosephusCheung/ACertainThing/resolve/main/ACertainThing.ckpt
echo '866946217b513157b12ff9b1eae2279e98ae34ece178e34eac536f2e831c101c  ACertainThing.ckpt' | sha256sum -c -
```

<details>

### ACertainty

- <https://huggingface.co/JosephusCheung/ACertainty>

```shell
wget https://huggingface.co/JosephusCheung/ACertainty/resolve/main/ACertainty.ckpt
echo 'a64573359af0f1071ef01d0dc93df2bc90eb1d0bcf3e26058fbf5aeff37c6462  ACertainty.ckpt' | sha256sum -c -
```

</details>

## Images

TBW

## Regularization Images

TBW

## Config

Create `work/20230225_001/config.json`.

```json
{
  "base_model": "/base_model/ACertainThing.ckpt",
  "img_folder": "/work/20230225_001/img",
  "reg_img_folder": "/work/20230225_001/reg_img",
  "output_folder": "/work/20230225_001/output"
}
```

## Run

- <https://github.com/derrian-distro/LoRA_Easy_Training_Scripts#list-of-arguments>

```shell
# Docker Engine >= 23.0
docker run --rm \
  --gpus all \
  -v "./base_model:/base_model" \
  -v "./work:/work" \
  lets \
  --load_json_path=/work/20230225_001/config.json
```
