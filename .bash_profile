export EDITOR="vim"
UNAME=`uname`
if [ -f ~/.BASH_IDENTITY ]; then
    source ~/.BASH_IDENTITY
else
echo "Your environment doesn't know who you are."
echo "Copy and paste the following lines into a file called ~/.BASH_IDENTITY"
echo "export GIT_AUTHOR_NAME="
echo "export GIT_AUTHOR_EMAIL="
echo "export GIT_COMMITTER_NAME=\"\$GIT_AUTHOR_NAME\""
echo "export GIT_COMMITTER_EMAIL=\"\$GIT_AUTHOR_EMAIL\""
fi

function find-ssh-agent () {
    if [ $UNAME = "Darwin" ]; then
        export SSH_AUTH_SOCK=$(find /tmp/launch-* -user `whoami` -name Listeners | tail -n 1)
    else
        export SSH_AUTH_SOCK=$(find /tmp/ssh-* -user `whoami` -name agent\* | tail -n 1)
    fi
    # Try to use it
    # 0 exit code means groovy
    # 1 exit code means no identities (yet)
    # 2 exit code means couldn't connect to agent
    ssh-add -l >/dev/null 2>&1
    result=$?
    if [ $result -eq 2 ]; then
        # Something didn't work.  Create a new one.
        eval `ssh-agent`
    fi
}


if [ -d ~/bin/ec2-api-tools ]; then 
    export EC2_HOME=~/bin/ec2-api-tools/
else
    echo "Your environment can't talk to EC2"
    echo "you'll need boto. git clone https://github.com/boto/boto.git"
    echo "you'll need the tools. curl -OL http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip"
fi


#Set up the paths
PATH="/sbin:/usr/sbin:/bin:/usr/bin"
for dir in /usr/local/bin /usr/X11/bin /usr/local/git/bin /usr/local/MacGPG2/bin ~/bin/ec2-api-tools/bin /usr/local/texlive/2011/bin/x86_64-darwin /usr/texbin; do
    if [ -d "$dir" ]; then
        PATH=$PATH:"$dir";
    fi
    export PATH
done

if [ $UNAME = "Darwin" ]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

if [ -f ~/.profile ]; then
    source ~/.profile
fi

rot13()
{
	if [ $# = 0 ] ; then
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
	else
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
	fi
}

watch()
{
        if [ $# -ne 1 ] ; then
                tail -f nohup.out
        else
                tail -f $1
        fi
}

find-ssh-agent


# csv from mysql output = mysql -e | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > filename.csv
function skip-first-n-lines() {
  perl -ne "print unless \$i++ < $1"
}

function start-ec2-instance() {
    #Be sure that the ec2 api tools are in your path.  Possibly in ~/Documents/ec2-api-tools-X.X.X.X/bin
    EC2_DESCRIBE="ec2-describe-instances"
    EC2_START="ec2-start-instances"
    INSTANCE_ID=$1


    #Already running?
    INSTANCE_STATUS=`$EC2_DESCRIBE $INSTANCE_ID | grep INSTANCE`
    INSTANCE_STATE=`echo $INSTANCE_STATUS |awk '{print $6}'`
    INSTANCE_ADDRESS=`echo $INSTANCE_STATUS |awk '{print $16}'`
    if [[ "$INSTANCE_STATE" == "running" ]]; 
    then 
        echo "$INSTANCE_ADDRESS";
    else 
        $EC2_START $INSTANCE_ID
        sleep 60
        INSTANCE_ADDRESS=`$EC2_DESCRIBE $INSTANCE_ID |grep INSTANCE |awk '{print $16}' `
    fi
    echo "$INSTANCE_ADDRESS";
}

function update-route53-dns () {
    # $2 is the address
    # $3 is the zone id
    # $4 is the full hostname
    echo "/usr/local/bin/route53 change_record $3 $4. A $2 300"
    /usr/local/bin/route53 change_record $3 $4. A $2 300
}

function start-oneleap-staging () {
    update-route53-dns `start-ec2-instance $ONELEAP_STAGING_INSTANCE_ID` $ONELEAP_ROUTE53_ZONE_ID staging.oneleap.to
}

function stop-oneleap-staging () {
    ec2-stop-instances $ONELEAP_STAGING_INSTANCE_ID
}
export PS1="\u@\h:\D{}:\w$ "
if [ $TERM == 'xterm-color' ] 
then
 export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}[`basename ${PWD}`]\007"'
fi

#'echo -ne "\033]0;iTools - mysql :: ${HOSTNAME}[`basename ${PWD}`]\007"'
