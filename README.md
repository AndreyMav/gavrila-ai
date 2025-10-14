# Gavrila AI - Automated Coding Agent

An intelligent automation system that integrates n8n workflows with GitHub Actions to create an AI-powered coding agent. Gavrila AI can receive tasks through Slack, process them using AI models, and execute automated coding workflows on GitHub repositories.

## ⚠️ Warning

**This project is intended as an example and educational resource to demonstrate how AI-powered automation can be achieved with n8n, GitHub Actions, and Augment Code. It is NOT intended for production use.**

**Use at your own risk.** This is a proof-of-concept implementation that may require significant modifications, security hardening, and testing before being suitable for any production environment. The authors assume no responsibility for any issues, data loss, or security vulnerabilities that may arise from using this code.

## Technologies Used

- **n8n** - Workflow automation platform (self-hosted on [Hostinger N8N VPC](https://www.hostinger.com/self-hosted-n8n))
- **GitHub Actions** - CI/CD automation and code execution
- **Augment Code (Auggie)** - AI-powered coding agent (Claude Sonnet 4.5 based)
- **Slack API** - Communication and task management
- **OpenAI/GPT Models** - AI-powered task processing and proofreading

## Prerequisites and Required Variables

Before setting up Gavrila AI, ensure you have:

### API Keys and Credentials
- **GitHub Personal Access Token** - Obtain from GitHub Settings > Developer settings > Personal access tokens
- **Slack App Credentials** - Create a Slack app at https://api.slack.com/apps
- **Augment Session Token** - Get from Augment Code platform (required for AI agent)
- **OpenAI API Key** - Get from https://platform.openai.com/api-keys (for task proofreading)
- **n8n Installation** - Self-hosted instance (see Hostinger VPC link above)

### Environment Setup
- **Repository Access** - Clone or fork this repository
- **n8n Webhook URLs** - Configure webhook endpoints in your n8n instance
- **Network Access** - Ensure n8n can reach GitHub and Slack APIs
- **Minimum Requirements**:
  - Node.js 16+ (for GitHub Actions scripts)
  - Docker 20+ (for n8n deployment)
  - 2GB RAM minimum for n8n instance

### Required Environment Variables

#### GitHub Repository Secrets
These must be configured in your GitHub repository settings (Settings > Secrets and variables > Actions):

```bash
# Augment Code Authentication (REQUIRED)
AUGMENT_TOKEN=your_augment_session_auth_token
```

#### n8n Environment Variables
These are configured within your n8n workflows:

```bash
# Slack Integration
SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxxxxxxxxxx
SLACK_SIGNING_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx

# OpenAI Integration (for task proofreading)
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxx

# n8n Configuration
N8N_WEBHOOK_URL=https://your-n8n-domain.com
N8N_WEBHOOK_PATH=/webhook/your-path
```

## Installation and Setup Steps

### 1. Repository Setup
```bash
# Clone the repository
git clone https://github.com/AndreyMav/gavrila-ai.git
cd gavrila-ai

# No additional dependencies to install - workflows run in n8n and GitHub Actions
```

### 2. n8n Deployment
Deploy n8n on your Hostinger VPC or preferred hosting platform:
```bash
# Using Docker (example)
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e WEBHOOK_URL="https://your-n8n-domain.com/" \
  n8nio/n8n
```

### 3. Configure GitHub Repository Secrets
1. Go to your GitHub repository > Settings > Secrets and variables > Actions
2. Add the following secret:
   - `AUGMENT_TOKEN` - Your Augment session authentication token (REQUIRED)

### 4. Import n8n Workflows
1. Access your n8n instance at `https://your-n8n-domain.com`
2. Import the workflow files from the `n8n/` directory:
   - `Gavrila - Hooks.json` - Main webhook handler for Slack commands
   - `Gavrila - Ask.json` - AI task processing and GitHub Actions orchestration
   - `Gavrila - Configure.json` - Repository configuration (update with your values)
   - `Gavrila - Ensure Task.json` - Task validation and creation
   - `Gavrila - Respond.json` - Response handling back to Slack
3. **Important**: Update the configuration in `Gavrila - Configure.json`:
   - `repository_url` - Set to your GitHub repository URL
   - `authorized_slack_user_ids` - Comma-separated list of authorized Slack user IDs (e.g., `U09LHK2NA3T,U12345678`)
   - `default_task_system` - Set to `github` or `linear` depending on your task management system

## How It Works

### Workflow Architecture

1. **Slack Command** → User sends a slash command (e.g., `/gavrila Fix the login bug`) in Slack
2. **n8n Webhook** → `Gavrila - Hooks` receives the command and performs authorization check:
   - Validates that the requesting user's Slack user ID is in the `authorized_slack_user_ids` list
   - If unauthorized, responds with "Sorry, I don't know you well enough." and stops processing
   - If authorized, sends acknowledgment to Slack and continues
3. **Task Processing** → `Gavrila - Ask` workflow:
   - Uses OpenAI to proofread and clarify the task instructions
   - Ensures a task exists (creates if needed)
   - Triggers GitHub Actions workflow `auggie-task.yml`
4. **GitHub Actions** → `auggie-task.yml` workflow:
   - Parses task context (from GitHub issue if provided)
   - Creates or switches to appropriate branch
   - Runs Augment Code agent with the task instructions
   - Commits and pushes changes
   - Reports back to n8n webhook
5. **Response** → `Gavrila - Respond` sends completion notification back to Slack

### n8n Workflow Details

The system uses several key n8n workflow configurations:

- **Webhook Nodes** - Receive incoming requests from Slack and GitHub Actions
- **GitHub Nodes** - Trigger GitHub Actions workflows and interact with repository
- **Slack Nodes** - Send messages, acknowledgments, and status updates
- **OpenAI Nodes** - Proofread task instructions and improve clarity
- **Execute Workflow Nodes** - Chain workflows together for complex operations

Workflow files are located in the `n8n/` directory and can be imported directly into your n8n instance. Each workflow handles a specific aspect of the automation pipeline.

## Setting up n8n Credentials

### Creating Credentials in n8n
1. Navigate to your n8n instance > **Credentials** section
2. Click **"Create New Credential"**
3. Select the appropriate credential type:
   - **GitHub API** - Use your GitHub Personal Access Token
   - **Slack API** - Use your Slack Bot Token
   - **OpenAI API** - Use your OpenAI API Key
4. Paste the API key/secret in the appropriate field
5. **Test the credential** using a sample node to verify connectivity
6. Save the credential with a descriptive name

### Documentation Links
- [n8n Credentials Documentation](https://docs.n8n.io/credentials/)
- [n8n General Documentation](https://docs.n8n.io/)

### Service-Specific Setup
- **GitHub**: Configure webhook URLs in repository settings if needed
- **Slack**: Install the Slack app in your workspace and configure slash commands
- **OpenAI**: Ensure sufficient API credits and rate limits

## Required API Key Permissions / Scopes

### GitHub
- `repo` - Full repository access (required for private repos)
- `workflow` - Trigger and manage GitHub Actions workflows
- `contents:write` - Push commits and create branches (automatically granted to GitHub Actions)
- `admin:repo_hook` - Manage repository webhooks (if webhook setup needed)
- `read:org` - Read organization data (if using organization repos)

### Augment Code
- Valid Augment session authentication token
- Access to Augment Code API
- Sufficient usage quota for AI-powered coding tasks

### Slack
- `chat:write` - Send messages and replies in channels and threads
- `channels:read` - Discover channel IDs and basic channel information
- `channels:history` - Read message history (if needed for context)
- `chat:write.public` - Post to public channels without being a member
- `commands` - Handle slash commands
- **Note**: Ensure thread replies are supported by using `thread_ts` parameter

### OpenAI
- Standard API access with sufficient usage limits
- Access to GPT models

## GitHub Actions Workflow

The main automation is powered by `.github/workflows/auggie-task.yml`, which:

### Workflow Inputs
- `taskJson` - JSON string containing task context (from GitHub issue or Slack)
- `branchName` - Optional branch name (auto-generated if not provided)
- `resumeUrl` - n8n webhook URL to report completion status
- `instructions` - Task instructions for the AI agent

### Workflow Steps
1. **Checkout repository** with full git history
2. **Parse task context** from JSON (supports GitHub issues)
3. **Determine branch name** from task context, timestamp, or provided input
4. **Create/switch to branch** and set up git configuration
5. **Build instruction file** with task details, comments, and context
6. **Run Augment Code agent** with the instruction file
7. **Commit and push changes** if any were made
8. **Report status** back to n8n webhook with summary

### Task JSON Format
The workflow accepts task context in the following format:
```json
{
  "task_id": "123",
  "task_system": "github",
  "url": "https://github.com/owner/repo/issues/123",
  "title": "Fix login bug",
  "author": "username",
  "state": "open",
  "instructions": "Task description...",
  "comments": [
    {
      "author": "username",
      "created_at": "2024-01-01T00:00:00Z",
      "body": "Comment text..."
    }
  ]
}
```

## Security and Access Control

### User Authorization
Gavrila AI includes built-in user authorization to control who can trigger the coding agent:

1. **Configure Authorized Users** in `Gavrila - Configure.json`:
   ```json
   {
     "authorized_slack_user_ids": "U09LHK2NA3T,U12345678,U87654321"
   }
   ```
   - Add comma-separated Slack user IDs of authorized users
   - Leave empty to allow all users (not recommended)

2. **How It Works**:
   - When a Slack slash command is received, the webhook extracts the `user_id` from the request
   - The `Gavrila - Hooks` workflow checks if the user ID is in the authorized list
   - Authorized users: Request proceeds normally
   - Unauthorized users: Receive message "Sorry, I don't know you well enough." and request is rejected

3. **Finding Slack User IDs**:
   - Click on a user's profile in Slack
   - Click "More" → "Copy member ID"
   - The ID format is typically `U` followed by alphanumeric characters (e.g., `U09LHK2NA3T`)

### Additional Security Considerations
- Store all API keys and tokens securely in GitHub Secrets and n8n credentials
- Use HTTPS for all webhook endpoints
- Verify Slack request signatures using the signing secret
- Regularly audit authorized user list and remove inactive users
- Monitor workflow execution logs for suspicious activity

## Slack Slash Commands Integration

Configure Slack slash commands to trigger n8n workflows:

### 1. Create Slack App
1. Go to https://api.slack.com/apps and create a new Slack app
2. Enable **"Slash Commands"** in your app features

### 2. Add Slash Command
1. Add a new slash command (e.g., `/gavrila` or `/task`)
2. Set **Request URL** to your n8n webhook endpoint:
   ```
   https://your-n8n-domain/webhook/your-path
   ```
3. Configure method as **POST** with content type `application/json`
4. Ensure the n8n Webhook node accepts the same method and content type

### 3. Install and Configure
1. Install the Slack app into your workspace
2. In n8n, create a Webhook node with matching path and method
3. Connect downstream nodes to process the incoming slash command payload

### 4. Security and Verification
1. Store your **Slack signing secret** securely
2. Verify incoming requests in n8n using the signing secret
3. Use n8n's built-in verification or custom verification logic
4. **User Authorization**: Configure `authorized_slack_user_ids` in `Gavrila - Configure.json`:
   - Add comma-separated Slack user IDs of authorized users (e.g., `U09LHK2NA3T,U12345678`)
   - The webhook will reject requests from unauthorized users with message: "Sorry, I don't know you well enough."
   - To find a user's Slack ID: Click on their profile → More → Copy member ID

### 5. Response Handling
1. **Respond quickly** (within 3 seconds) to avoid Slack timeouts
2. For longer processing, return immediate acknowledgment:
   ```json
   {
     "response_type": "ephemeral",
     "text": "Processing your request..."
   }
   ```
3. Use `response_url` for follow-up messages or separate Slack API calls

### 6. Optional Settings
- **Response visibility**: Use `in_channel` (public) or `ephemeral` (private)
- **Environment variables**: Add `SLACK_WEBHOOK_URL` and `SLACK_SIGNING_SECRET`
- **Payload fields**: Expect `command`, `text`, `user_id`, `channel_id`, `response_url`
- **User authorization**: The `user_id` field is used to verify authorized users against the configured list

## Usage and Testing

### Starting the System
1. Ensure n8n workflows are active and running
2. Verify GitHub Actions workflow is enabled in repository settings
3. Confirm GitHub repository secret is configured (`AUGMENT_TOKEN`)
4. Test Slack integration with a simple slash command

### Sample Test Cases

#### Basic Slack Command
1. **Send Slack command**: `/gavrila Create a simple test task`
2. **Verify n8n processing**: Check n8n execution logs for workflow execution
3. **Check GitHub**: Confirm GitHub Actions workflow triggered in Actions tab
4. **Monitor progress**: Watch the workflow execution in real-time
5. **Validate response**: Ensure Slack receives completion notification with summary

#### With GitHub Issue
1. **Create GitHub issue**: Create an issue in your repository (e.g., `#123`)
2. **Send Slack command**: `/gavrila #123 Implement the feature as described`
3. **Verify workflow**: Check that task details are fetched from GitHub
4. **Check branch**: Verify branch name is created appropriately
5. **Validate completion**: Ensure GitHub issue is referenced in commit

### End-to-End Functionality Checklist
- [ ] Slack slash command triggers n8n webhook
- [ ] User authorization check passes (user ID is in authorized list)
- [ ] n8n sends immediate acknowledgment to Slack
- [ ] OpenAI proofreads and clarifies task instructions
- [ ] n8n triggers GitHub Actions workflow with task context
- [ ] GitHub Actions creates/switches to appropriate branch
- [ ] Augment Code agent executes coding task
- [ ] Changes are committed and pushed to repository
- [ ] Workflow reports status back to n8n
- [ ] Slack receives completion notification with summary

## Troubleshooting and Links

### Common Issues

#### Augment Code Errors
- **Authentication failed**: Verify `AUGMENT_TOKEN` secret is correctly set in GitHub repository
- **Token expired**: Refresh your Augment session token and update the secret
- **Quota exceeded**: Check your Augment usage limits and plan

#### GitHub Actions Issues
- **Workflow not triggering**: Ensure n8n has correct repository URL and workflow filename
- **Permission denied on push**: Verify workflow has `contents: write` permission
- **Branch creation fails**: Check if branch already exists or naming conflicts

#### n8n Workflow Issues
- **Credential errors**: Verify API keys and permissions in n8n credentials section
- **Workflow not active**: Ensure all workflows are activated in n8n
- **Network issues**: Ensure n8n can reach external APIs (GitHub, Slack, OpenAI, Linear)
- **Webhook timeouts**: Verify webhook URLs and n8n workflow activation
- **GitHub API rate limits**: Check if you've exceeded GitHub API rate limits

#### Slack Integration Issues
- **Slash command not responding**: Check n8n webhook URL configuration in Slack app
- **Verification failures**: Verify signing secret configuration in n8n
- **Message not posting**: Ensure Slack bot has correct permissions and is in the channel
- **"Sorry, I don't know you well enough" error**: User is not in the `authorized_slack_user_ids` list in `Gavrila - Configure.json`
  - Verify the user's Slack ID is correctly added to the configuration
  - Ensure IDs are comma-separated without spaces (or with consistent spacing)
  - Check that the `Gavrila - Configure` workflow is properly connected to `Gavrila - Hooks`

### Helpful Resources
- [Augment Code Documentation](https://docs.augmentcode.com/)
- [Augment Code GitHub Action](https://github.com/augmentcode/augment-agent)
- [n8n Documentation](https://docs.n8n.io/)
- [Hostinger N8N VPC](https://www.hostinger.com/self-hosted-n8n)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [Slack API Documentation](https://api.slack.com/web)
- [OpenAI API Documentation](https://platform.openai.com/docs)

## Contributing, License, and Contact

### Contributing
- Fork the repository and create feature branches
- Follow existing code style and n8n workflow patterns
- Submit pull requests with clear descriptions
- Test workflows thoroughly before submitting
- Update documentation when adding new features

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Contact
- **Repository**: https://github.com/AndreyMav/gavrila-ai
- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and community support

---

**Built with ❤️ using Augment Code, n8n, and GitHub Actions**
