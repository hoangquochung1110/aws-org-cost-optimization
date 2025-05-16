import boto3
import json
import logging
import os
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

# Constants
APPLICABLE_RESOURCES = ['AWS::EC2::Volume']
NON_COMPLIANT_TYPE = 'gp2'
IS_LOCAL = os.environ.get('AWS_SAM_LOCAL') == 'true'


def lambda_handler(event, context):
    """
    Lambda function to check if EBS volumes are of type gp2 and flag them as non-compliant.
    Volumes should be gp3 or other types for compliance.
    """
    logger.info('Starting EBS volume type check')
    logger.debug(f'Event received: {json.dumps(event)}')
    
    evaluations = []
    
    try:
        # Extract the invoking event
        invoking_event = json.loads(event['invokingEvent'])
        event_type = invoking_event.get('messageType')
        rule_parameters = {}
        
        if 'ruleParameters' in event:
            rule_parameters = json.loads(event.get('ruleParameters', '{}'))
        
        logger.info(f'Event type: {event_type}')
        
        # Handle different event types
        if event_type == 'ConfigurationItemChangeNotification':
            evaluations = handle_configuration_change(invoking_event, event)
        elif event_type == 'ScheduledNotification':
            evaluations = handle_scheduled_evaluation(event, context)
        else:
            logger.warning(f'Unsupported message type: {event_type}')
        
        # Submit evaluation results to AWS Config
        if evaluations:
            if not IS_LOCAL:
                # Initialize AWS Config client
                config_client = boto3.client('config')
                config_client.put_evaluations(
                    Evaluations=evaluations,
                    ResultToken=event['resultToken']
                )
        logger.info(f'Completed evaluation with {len(evaluations)} results')
        return evaluations

    except Exception as e:
        logger.error(f'Error executing Lambda: {str(e)}')
        raise

def handle_configuration_change(invoking_event, event):
    """Handle evaluation for a configuration change notification"""
    evaluations = []
    
    try:
        # Extract the configuration item
        configuration_item = invoking_event.get('configurationItem', {})
        
        # Skip if resource is not applicable
        if configuration_item.get('resourceType') not in APPLICABLE_RESOURCES:
            logger.info(f"Resource type {configuration_item.get('resourceType')} is not applicable")
            evaluations.append(
                create_evaluation(
                    event['configRuleName'],
                    'NOT_APPLICABLE',
                    configuration_item.get('resourceId', 'unknown'),
                    configuration_item.get('resourceType', 'unknown'),
                    'This rule only applies to EC2 volumes.'
                )
            )
            return evaluations
        
        # Handle deleted resources
        status = configuration_item.get('configurationItemStatus')
        if status == 'ResourceDeleted':
            logger.info(f"Resource {configuration_item.get('resourceId')} was deleted")
            evaluations.append(
                create_evaluation(
                    event['configRuleName'],
                    'NOT_APPLICABLE',
                    configuration_item.get('resourceId'),
                    configuration_item.get('resourceType'),
                    'Resource has been deleted'
                )
            )
            return evaluations
        
        # Check compliance
        if 'configuration' not in configuration_item:
            logger.warning(f"No configuration found in the configuration item")
            evaluations.append(
                create_evaluation(
                    event['configRuleName'],
                    'INSUFFICIENT_DATA',
                    configuration_item.get('resourceId'),
                    configuration_item.get('resourceType'),
                    'No configuration data available'
                )
            )
            return evaluations
        
        volume_id = configuration_item['configuration'].get('volumeId')
        volume_type = configuration_item['configuration'].get('volumeType')
        
        logger.debug(f'Checking volume {volume_id} of type {volume_type}')
        
        if volume_type == NON_COMPLIANT_TYPE:
            evaluations.append(
                create_evaluation(
                    event['configRuleName'],
                    'NON_COMPLIANT',
                    volume_id,
                    configuration_item.get('resourceType'),
                    f'Volume {volume_id} is of type {NON_COMPLIANT_TYPE} and should be converted to gp3'
                )
            )
        else:
            evaluations.append(
                create_evaluation(
                    event['configRuleName'],
                    'COMPLIANT',
                    volume_id,
                    configuration_item.get('resourceType'),
                    f'Volume {volume_id} is not of type {NON_COMPLIANT_TYPE}'
                )
            )
        
        return evaluations
    
    except Exception as e:
        logger.error(f"Error in handle_configuration_change: {str(e)}")
        raise

def handle_scheduled_evaluation(event, context):
    """Handle evaluation for scheduled notifications by checking all applicable resources"""
    evaluations = []
    
    try:
        ec2_client = boto3.client('ec2')
        
        # Get all EBS volumes with pagination
        paginator = ec2_client.get_paginator('describe_volumes')
        
        for page in paginator.paginate():
            for volume in page.get('Volumes', []):
                volume_id = volume.get('VolumeId')
                volume_type = volume.get('VolumeType')
                
                logger.debug(f'Checking volume {volume_id} of type {volume_type}')
                
                # Check if volume is of the non-compliant type
                if volume_type == NON_COMPLIANT_TYPE:
                    evaluations.append(
                        create_evaluation(
                            event['configRuleName'],
                            'NON_COMPLIANT',
                            volume_id,
                            'AWS::EC2::Volume',
                            f'Volume {volume_id} is of type {NON_COMPLIANT_TYPE} and should be converted to gp3'
                        )
                    )
                else:
                    evaluations.append(
                        create_evaluation(
                            event['configRuleName'],
                            'COMPLIANT',
                            volume_id,
                            'AWS::EC2::Volume',
                            f'Volume {volume_id} is not of type {NON_COMPLIANT_TYPE}'
                        )
                    )
        
        return evaluations
    
    except Exception as e:
        logger.error(f"Error in handle_scheduled_evaluation: {str(e)}")
        raise

def create_evaluation(config_rule_name, compliance_type, resource_id, resource_type, annotation=None):
    """Create an evaluation dictionary for AWS Config"""
    evaluation = {
        'ComplianceResourceType': resource_type,
        'ComplianceResourceId': resource_id,
        'ComplianceType': compliance_type,
        'OrderingTimestamp': datetime.utcnow().timestamp()
    }
    
    if annotation:
        evaluation['Annotation'] = annotation
    
    logger.info(f'Creating evaluation: {json.dumps(evaluation)}')
    
    return evaluation
