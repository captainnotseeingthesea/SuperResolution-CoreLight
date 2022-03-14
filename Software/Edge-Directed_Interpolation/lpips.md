## intsall pyorch (if not installed)
The following command installs the CPU version of pytorch, 
because there is a problem with my GPU driver, and the CPU version is enough.

`pip3 install torch==1.11.0+cpu torchvision==0.12.0+cpu torchaudio==0.11.0+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html`

## clone the repository
`git clone https://github.com/richzhang/PerceptualSimilarity`

`cd PerceptualSimilarity`


## run
Just modified the parameter `-p0` and `-p1` is enough.
On the first run, you need to download the weights.
### run with cpu
`python3 lpips_2imgs.py -p0 imgs/ex_ref.png -p1 imgs/ex_p0.png`

### run with gpu
`python3 lpips_2imgs.py -p0 imgs/ex_ref.png -p1 imgs/ex_p0.png --use_gpu`

If something goes wrong, maybe you should install the requirements first.

`pip3 install -r requirements.txt`

