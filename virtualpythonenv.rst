Installation using setuptools and pip
NOTE: If you don't want to touch system files or you don't have root, please see this question on stackoverflow. For everyone else please read on...

Install setuptools and pip
According to the distribute website setuptools and easy_install are old and busted (the version included in Ubuntu 12.04 doesn't work with python3), and distribute and pip are the new hotness. So we will use those:

EDIT: Since September 2014, distribute has been merged back into setuptools. So we can use setuptools and easy_install again to install pip. Use:

wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
or

wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python3
if you're using python 3, then install pip with

sudo easy_install pip
Optional: Turn on bash autocomplete for pip
Run

pip completion --bash >> ~/.bashrc
and run source ~/.bashrc to enable

Use pip to install virtualenv and virtualenvwrapper
The reason we are also installing virtualenvwrapper is because it offers nice and simple commands to manage your virtual environments.

sudo pip install virtualenv
sudo pip install virtualenvwrapper
Setup virtualenv
First we export the WORKON_HOME variable which contains the directory in which our virtual environments are to be stored. Let's make this ~/.virtualenvs

export WORKON_HOME=~/.virtualenvs
now also create this directory

mkdir $WORKON_HOME
and put this export in our ~/.bashrc file so this variable gets automatically defined

echo "export WORKON_HOME=$WORKON_HOME" >> ~/.bashrc
Setup virtualenvwrapper
To use virtualenvwrapper we need to import its functions in our ~/.bashrc

echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
We can also add some extra tricks like the following, which makes sure that if pip creates an extra virtual environment, it is also placed in our WORKON_HOME directory:

echo "export PIP_VIRTUALENV_BASE=$WORKON_HOME" >> ~/.bashrc 
Source ~/.bashrc to load the changes

source ~/.bashrc
Test if it works

Now we create our first virtual environment

mkvirtualenv test
You will see that the environment will be set up, and your prompt now includes the name of your active environment in parentheses. Also if you now run

python -c "import sys; print sys.path"
you should see a lot of /home/user/.virtualenv/... because it now doesn't use your system site-packages.

You can deactivate your environment by running

deactivate
and if you want to work on it again, simply type

workon test
Finally, if you want to delete your environment, type

rmvirtualenv test
