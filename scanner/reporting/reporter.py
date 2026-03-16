import json
import logging

class Reporter:
    def __init__(self, output_file="report.json"):
        self.output_file = output_file

    def generate_json(self, issues):
        try:
            with open(self.output_file, 'w') as f:
                json.dump(issues, f, indent=4)
            logging.info(f"JSON report generated: {self.output_file}")
        except Exception as e:
            logging.error(f"Failed to generate JSON report: {str(e)}")

    def generate_markdown(self, issues, md_file="report.md"):
        md_content = "# Web Vulnerability Scan Report\n\n"
        
        if not issues:
            md_content += "No vulnerabilities found.\n"
        else:
            # Sort issues by severity
            severity_order = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2, "LOW": 3, "INFO": 4}
            sorted_issues = sorted(issues, key=lambda x: severity_order.get(x.get("severity", "INFO"), 5))
            
            md_content += "| Severity | Type | URL | Description |\n"
            md_content += "| --- | --- | --- | --- |\n"
            
            for issue in sorted_issues:
                md_content += f"| {issue.get('severity', 'INFO')} | {issue.get('type')} | {issue.get('url')} | {issue.get('description')} |\n"
            
            md_content += "\n## Detailed Findings\n"
            for i, issue in enumerate(sorted_issues):
                md_content += f"### {i+1}. {issue.get('type')} ({issue.get('severity')})\n"
                md_content += f"- **URL:** {issue.get('url')}\n"
                md_content += f"- **Description:** {issue.get('description')}\n"
                if "snippet" in issue:
                    md_content += f"- **Snippet:**\n```html\n{issue.get('snippet')}\n```\n"
                if "ai_analysis" in issue:
                    md_content += f"- **AI Analysis:**\n{issue.get('ai_analysis')}\n"
                md_content += "---\n"

        try:
            with open(md_file, 'w', encoding='utf-8') as f:
                f.write(md_content)
            logging.info(f"Markdown report generated: {md_file}")
        except Exception as e:
            logging.error(f"Failed to generate Markdown report: {str(e)}")
