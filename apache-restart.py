import json
import time
import boto3

ssm_client = boto3.client('ssm')

def lambda_handler(event, context):
    instance_id = event['instsance_id']  # Mention your EC2 Instance id in event

    # Command to check if Apache is running
    check_command = "systemctl is-active apache2"

    # Execute the command to check Apache status
    response = ssm_client.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={'commands': [check_command]}
    )

    command_id = response['Command']['CommandId']

    # Wait for the command to complete
    time.sleep(5)  # Initial wait before checking command status

    for _ in range(10):  # Retry up to 10 times
        try:
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id,
            )
            if output['Status'] == 'Success':
                break
        except ssm_client.exceptions.InvocationDoesNotExist:
            time.sleep(5)  # Wait before retrying

    # Check if Apache is inactive
    if 'inactive' in output['StandardOutputContent'].lower():
        # Command to restart Apache
        restart_command = "sudo systemctl restart apache2"
        
        # Execute the command to restart Apache
        ssm_client.send_command(
            InstanceIds=[instance_id],
            DocumentName="AWS-RunShellScript",
            Parameters={'commands': [restart_command]}
        )

        return {
            'statusCode': 200,
            'body': json.dumps('Apache restarted')
        }

    return {
        'statusCode': 200,
        'body': json.dumps('Apache is running')
    }
