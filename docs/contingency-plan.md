# DKAN/HDG SSP Appendix V: Contingency Plan

**U. S. Department of Health and Human Services (HHS)**

<img src="media/hhs_logo_222x224.png" alt="HHS Logo" width="222" height="224" />

**System Security Plan (SSP)**

**Appendix V: Information System Contingency Plan (ISCP)**

***for***

**Office of the Secretary (OS)**

**HealthData.gov (HDG)**

| Submitted: November 22, 2017 to Gregory Downing     |
|-----------------------------------------------------|
| HHS/OS/OCIO                                         |
| 200 Independence Ave., S.W., Washington, D.C. 20201 |


Table of Contents
=================

* [Overview](#overview)
* [Recovery objective](#recovery-objective)
* [Incident Response Team information](#incident-response-team-information)
  * [Contact information](#contact-information)
* [Contingency plan outline](#contingency-plan-outline)
  * [Activation and notification](#activation-and-notification)
  * [Recovery](#recovery)
  * [Reconstitution](#reconstitution)
* [External dependencies](#external-dependencies)
* [How this document works](#how-this-document-works)

## Overview

This Contingency Plan provides guidance for our team in the case of trouble delivering our essential mission and business functions because of disruption, compromise, or failure of any component of DKAN/HDG. As a general guideline, we consider "disruption" to mean unexpected downtime or significantly reduced service lasting longer than:
* 30 minutes 0900 - 2100 Eastern Time Monday through Friday (standard U.S. business hours)
* 90 minutes at other times

Scenarios where that could happen include unexpected downtime of key services, data loss, or improper privilege escalation. In the case of a security incident, the team uses the [Security Incident Response Procedure](incident-response-plan.md) as well.

## Recovery objective

Short-term disruptions lasting less than 30 minutes are outside the scope of this plan.

More than 3 hours of any DKAN/HDG service being offline during standard U.S. business hours (0900 - 2100 Eastern Time) would be unacceptable. Our objective is to recover from any significant problem (disruption, compromise, or failure) within that span of time.

## Incident Response Team information

### Contact information

Team contact information is available in the DKAN/HDG Google Drive:

* [CivicActions/DKAN/HDG Incident Response Team contact sheet](https://docs.google.com/a/civicactions.net/spreadsheets/d/1kKxnN_A8QNoJLVtD-q5bpZZh4-0_hsziRckQUYcBJCU/edit?usp=sharing) with names and roles for CivicActions and DKAN/HDG Incident Response Team members.

## Contingency plan outline

### Activation and notification

The first Incident Response Team member who notices or reports a potential contingency-plan-level problem becomes the **Incident Commander** (IC) until recovery efforts are complete or the Incident Commander role is explicitly reassigned.

If the problem is identified as part of a [security incident response situation](incident-response-plan.md) (or becomes a security incident response situation), the same Incident Commander (IC) should handle the overall situation, since these response processes must be coordinated.

The IC first notifies and coordinates with the people who are authorized to decide that DKAN/HDG is in a contingency plan situation:

* From CivicActions:
    * Incident Commander
    * Project Manager
	* CivicActions Incident Response Team
* DKAN/HDG
    * Product Owner
	* DKAN/HDG users, when applicable

The IC keeps a log of the situation in a GitHub issue; if this is also a security incident, the IC also follows the [security incident communications process](incident-response-plan.md#initiate) which includes updating the [`#engineering-dkan`](https://civicactions.slack.com/messages/engineering-dkan/) Slack channel. The IC should delegate assistant ICs for aspects of the situation as necessary.

### Recovery

The Incident Response Team assesses the situation and works to recover the system. See the list of [external dependencies](#external-dependencies) for procedures for recovery from problems with external services.

If this is also a security incident, the IC also follows the security incident [assessment](incident-response-plan.md#initiate) and [remediation](incident-response-plan.md#remediation) processes.

If the IC assesses that the overall response process is likely to last longer than 3 hours, the IC should organize shifts so that each responder works on response for no longer than 3 hours at a time, including handing off their own responsibility to a new IC after 3 hours.

### Reconstitution

The Incident Response Team tests and validates the system as operational.

The Incident Commander declares that recovery efforts are complete and notifies all relevant people. The last step is to schedule a postmortem in the GitHub issue (as part of the same of a new ticket) to discuss the event. This is the same as the [security incident retrospective process](incident-response-plan.md#initiate).

## External dependencies

DKAN/HDG depends on several external services.  In the event one or more of these services has a long-term disruption, the team will mitigate impact by following this plan.

#### GitHub <https://github.com/NuCivic/healthdata/>
If GitLab becomes unavailable, DKAN/HDG will continue to operate in its current state. The disruption would only impact the team's ability to update code on the instances.

#### StatusCake <https://app.statuscake.com/>
If there is a disruption in the StatusCake service, the Incident Response team will be notified by email.

#### OpsGenie <https://app.opsgenie.com/alert/V2/>
If there is a disruption in the OpsGenie service, all alerts automatically get delivered to the team via email.

#### Slack <https://civicactions.slack.com/messages/engineering-dkan/>
There is no direct impact to the platform if a disruption occurs. Primary incident communications will move to the <https://hangouts.google.com/hangouts/_/civicactions.net/engineering-dkanscrum> Google Hangout.

#### Acquia Cloud Disaster Recovery Backups <https://docs.acquia.com/acquia-cloud/arch/availability/backups>
Acquia Cloud takes hourly snapshots of EBS volumes that are saved to Amazon S3 providing distibuted saves to geographically distributed data centers. Acquia maintains a week of daily snapshots, a month of weekly snapshots and three months of monthly snapshots.

#### Acquia Cloud Nightly MySQL Database Dumps
Nightly database dumps are created and saved for three days to facilitate restoration by Developers and/or the Incident Response Team.

#### Acquia Cloud Enterprise <https://cloud.acquia.com/app/develop>
DKAN/HDG is hosted on the Acquia Cloud Enterprise (ACE) PaaS which is layered on top of the Amazon Web Services (AWS) FedRAMP-certified cloud in the us-east region. See [ACE Status](https://status.acquia.com/) and [AWS status](http://status.aws.amazon.com/).

In case of a **significant** disruption, after receiving approval from our Authorizing Official, the CivicActions and Acquia teams will deploy a new instance of the entire system to a different region.

## How this document works

This plan is most effective if all core CivicActions team members know about it, remember that it exists, have the ongoing opportunity to give input based on their expertise, and keep it up to date.

* The CivicActions team is responsible for maintaining this document and updating it as needed. Any change to it must be approved and peer reviewed by at least another member of the team.
  * All changes to the plan should be communicated to the rest of the team.
  * At least once a year, and after major changes to our systems, we review and update the plan.
* How we protect this plan from unauthorized modification:
  * This plan is stored in the CivicActions Gitlab repository (<https://git.civicactions.net/engineering-dkan/compliance/>) with authorization to modify it limited to the Incident Response Team by Gitlab access controls. CivicActions policy is that changes are proposed by making a pull request and ask another team member to review and merge the pull request.
