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

#Set up the paths
PATH="/sbin:/usr/sbin:/bin:/usr/bin"
for dir in /usr/local/bin /usr/X11/bin /usr/local/git/bin /usr/local/MacGPG2/bin /Users/alt/Documents/ec2-api-tools-1.5.2.4/bin /usr/local/texlive/2011/bin/x86_64-darwin /usr/texbin; do
    if [ -d "$dir" ]; then
        PATH=$PATH:"$dir";
    fi
    export PATH
done

#####  Screen can work with ssh-agent even when you reconnect
#if [ -n "$SSH_AUTH_SOCK" ];
  #then screen_ssh_agent="/tmp/${USER}-screen-ssh-agent.sock"
  #if [ ${STY} ];
    #then if [ -e ${screen_ssh_agent} ];
      #then export SSH_AUTH_SOCK=${screen_ssh_agent}
    #fi else ln -snf ${SSH_AUTH_SOCK} ${screen_ssh_agent}
  #fi
#fi
###### Screen/ssh-agent stuff ends here
validagent=/tmp/$USER-ssh-agent/valid-agent
validagentdir=`dirname ${validagent}`
# if it's not a directory or it doesn't exist, make it.
if [ ! -d ${validagentdir} ]
then
    # just in case it's a file
    rm -f ${validagentdir}
    mkdir -p ${validagentdir}
    chmod 700 ${validagentdir}
fi
# only proceed if it's owned by me
if [ -O ${validagentdir} ]
then
    # and the ssh socket isn't already the symlink
    if [ "x$validagent" != "x$SSH_AUTH_SOCK" ]
    then
        # and the socket actually exists and is a socket
        if [ -S $SSH_AUTH_SOCK ]
        then
            # and it's not empty (i.e. no forwarded agent)
            if [ ! -z $SSH_AUTH_SOCK ]
            then
                # if the current symlink works, don't touch it.
                orig_sock=$SSH_AUTH_SOCK
                SSH_AUTH_SOCK=${validagent}
                # can ssh-add get a listing of keys from the agent?
                ssh-add -l >/dev/null 2>&1
                result=$?
                fi
            fi
        fi
    fi
fi

if [ $UNAME = "Darwin" ]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

if [ -f ~/.profile ]; then
    source ~/.profile
fi


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
