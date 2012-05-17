export EDITOR="vim"
UNAME=`uname`
echo "Welcome $USER"
if [ -f ~/.BASH_IDENTITY ]; then
    source ~/.BASH_IDENTITY
else
echo "Your environment doesn't know who you are."
echo "Copy and paste the following lines into a file called ~/.BASH_IDENTITY"
echo "export GIT_AUTHOR_NAME="
echo "export GIT_AUTHOR_EMAIL="
echo "export GIT_COMMITTER_NAME=\"$GIT_AUTHOR_NAME\""
echo "export GIT_COMMITTER_EMAIL=\"$GIT_AUTHOR_EMAIL\""
fi


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
                if [ $result -ne 0 ] 
                then    
                    # ${validagent} is not valid.  make it so!

                    # make sure tmpreaper doesn't remove my dir
                    touch $validagentdir
                    # make the symlink
                    ln -sf $orig_sock $validagent
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


# csv from mysql output = mysql -e | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > filename.csv
function skip-first-n-lines() {
  perl -ne "print unless \$i++ < $1"
}
