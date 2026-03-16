import re
import asyncio
from bs4 import BeautifulSoup
import requests

class ActiveScanner:
    def __init__(self):
        # Basic payloads for detection
        self.sqli_payloads = ["'", "''", "OR 1=1", "\""]
        self.xss_payloads = ["<script>alert(1)</script>", "javascript:alert(1)", "<img src=x onerror=alert(1)>"]

    async def scan_url(self, url, content):
        issues = []
        soup = BeautifulSoup(content, 'html.parser')
        
        # 1. SQLi Heuristic: Find forms and parameters
        for form in soup.find_all('form'):
            inputs = form.find_all(['input', 'textarea'])
            if inputs:
                issues.append({
                    "url": url,
                    "type": "Potential SQLi / Form Injection",
                    "severity": "HIGH",
                    "description": f"Form found with {len(inputs)} input fields. Needs active testing.",
                    "snippet": str(form)[:500]
                })

        # 2. XSS Heuristic: Reflection points
        # If a URL has parameters, it might be vulnerable to reflection
        if '?' in url:
             issues.append({
                "url": url,
                "type": "Potential Reflected XSS",
                "severity": "MEDIUM",
                "description": "URL contains parameters. Test for reflection.",
                "snippet": url
            })

        return issues
