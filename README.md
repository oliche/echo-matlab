# echo-matlab
This is a library of basic, self-containing simple seismic processing tools.
The purpose is to have an open-source common set of building blocks for closed-source projects.

## Installation: setting the Matlab path
Git clone (recommended) or download the repository.
Then either through the Matlab menu Home -> set path -> add with subfolders, or from the command line:
```matlab
code_folder = '/home/user/MATLAB/das-prm';
addpath(genpath(code_folder))
```

## running the tests
 `./test/run_test.m`
