# Splunk Soc Analyst Lab

## This is my Splunk SOC Analyst Lab training repo.

You are absolutely welcome to contribute to it and share it with others.

_Warning: This is to be run on Windows-based virtual machines only._

## Introduction:

The Runner includes a mix of scenarios written by me and scenarios generated with help from ChatGPT. It runs benign, lab-safe events designed to simulate SOC analyst cases that can be investigated and turned into a full incident story. The Cleanup file contains the code needed to reverse the Runner’s changes and restore the lab environment.

## Prerequisites

You need to install Sysmon on your Windows virtual machine. To install Sysmon, follow this YouTube video: <u>https://www.youtube.com/watch?v=uJ7pv6blyog</u>

## How to use:

1. Install the latest version of Splunk.
2. Make sure to copy the inputs.conf file to this path: C:\Program Files\Splunk\etc\system\local. This will allow Splunk to read events from multiple sources.
3. Restart Splunk by running this command: `& "C:\Program Files\Splunk\bin\splunk.exe" restart`
4. Open ChatGPT or any other AI tool of your choosing, and give it the **SOC_Analyst_Lab_Lead_Master_Prompt.txt** file alongside the two PowerShell files (Runner and Cleanup).
5. Run the Runner code file using PowerShell as an **Administrator**: `.\SOC_Blind_Case_Runner_v2.ps1`. This should emit a SOC case code; feed it to the AI tool that you are using.
6. Investigate the events that the Runner code produced.
7. Have fun.
