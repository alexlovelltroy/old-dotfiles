export editor="vim"
uname=`uname`
if [ -f ~/.bash_identity ]; then
    source ~/.bash_identity
else
echo "your environment doesn't know who you are."
echo "copy and paste the following lines into a file called ~/.bash_identity"
echo "export git_author_name="
echo "export git_author_email="
echo "export git_committer_name=\"\$git_author_name\""
echo "export git_committer_email=\"\$git_author_email\""
fi

if [ -d ~/bin/ec2-api-tools ]; then 
    export ec2_home=~/bin/ec2-api-tools/
else
    echo "your environment can't talk to ec2"
    echo "you'll need boto. git clone https://github.com/boto/boto.git"
    echo "you'll need the tools. curl -ol http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip"
fi


#set up the paths
path="/sbin:/usr/sbin:/bin:/usr/bin"
for dir in /usr/local/bin /usr/x11/bin /usr/local/git/bin /usr/local/macgpg2/bin ~/bin/ec2-api-tools/bin /usr/local/texlive/2011/bin/x86_64-darwin /usr/texbin; do
    if [ -d "$dir" ]; then
        path=$path:"$dir";
    fi
    export path
done
# test for the existence of an auth sock var
if [ -z "$ssh_auth_sock" ]; then
	export ssh_auth_sock=$(find /tmp/ssh-* -user `whoami` -name agent\* | tail -n 1)
else
    # try to use it
    # 0 exit code means groovy
    # 1 exit code means something failed
    # 2 exit code means couldn't connect to agent
    ssh-add -l >/dev/null 2>&1
    result=$?
    if [ $result -ne 0 ]; then
        # something didn't work.  create a new one.
	eval `ssh-agent`
    fi
fi

if [ $uname = "darwin" ]; then
    alias ls='ls -g'
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
    #be sure that the ec2 api tools are in your path.  possibly in ~/documents/ec2-api-tools-x.x.x.x/bin
    ec2_describe="ec2-describe-instances"
    ec2_start="ec2-start-instances"
    instance_id=$1


    #already running?
    instance_status=`$ec2_describe $instance_id | grep instance`
    instance_state=`echo $instance_status |awk '{print $6}'`
    instance_address=`echo $instance_status |awk '{print $16}'`
    if [[ "$instance_state" == "running" ]]; 
    then 
        echo "$instance_address";
    else 
        $ec2_start $instance_id
        sleep 60
        instance_address=`$ec2_describe $instance_id |grep instance |awk '{print $16}' `
    fi
    echo "$instance_address";
}

function update-route53-dns () {
    # $2 is the address
    # $3 is the zone id
    # $4 is the full hostname
    echo "/usr/local/bin/route53 change_record $3 $4. a $2 300"
    /usr/local/bin/route53 change_record $3 $4. a $2 300
}

function start-oneleap-staging () {
    update-route53-dns `start-ec2-instance $oneleap_staging_instance_id` $oneleap_route53_zone_id staging.oneleap.to
}

function stop-oneleap-staging () {
    ec2-stop-instances $oneleap_staging_instance_id
}
export ps1="\u@\h:\d{}:\w$ "
if [ $term == 'xterm-color' ] 
then
 export prompt_command='echo -ne "\033]0;${user}@${hostname}[`basename ${pwd}`]\007"'
fi

#'echo -ne "\033]0;itools - mysql :: ${hostname}[`basename ${pwd}`]\007"'
