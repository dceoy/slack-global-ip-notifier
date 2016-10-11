slack_global_ip_notifier
========================

Slack notifier of global IP

Usage
-----

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/slack_global_ip_notifier.git
    $ cd slack_global_ip_notifier
    ```

2.  Set `slack_env.sh`.

    ```sh
    $ cp example_slack_env.sh slack_env.sh
    $ vi slack_env.sh # => set environment variables for slack notification
    ```

3.  Test notification.

    ```sh
    $ ./run.sh --force
    ```

4.  Set `crontab`.

    ```sh
    $ echo "0 * * * * $(pwd)/run.sh >> $(pwd)/log/global_ip.log 2>&1" > crontab
    $ crontab crontab
    ```
