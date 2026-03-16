from bs4 import BeautifulSoup
import re

class PassiveScanner:
    def __init__(self):
        self.vulnerabilities = []

    def scan(self, url, content, headers):
        issues = []
        
        # 1. Check for missing security headers
        security_headers = {
            "Content-Security-Policy": "Missing Content-Security-Policy header",
            "X-Frame-Options": "Missing X-Frame-Options header (Clickjacking risk)",
            "Strict-Transport-Security": "Missing Strict-Transport-Security header",
            "X-Content-Type-Options": "Missing X-Content-Type-Options header",
            "Referrer-Policy": "Missing Referrer-Policy header"
        }
        
        for header, message in security_headers.items():
            if header not in headers:
                issues.append({
                    "url": url,
                    "type": "Missing Header",
                    "severity": "LOW",
                    "description": message
                })

        # 2. Check for sensitive information in meta tags
        soup = BeautifulSoup(content, 'html.parser')
        
        # 3. Check for deprecated tags (like in crawler.sh)
        deprecated_tags = ['marquee', 'blink']
        for tag in deprecated_tags:
            if soup.find(tag):
                issues.append({
                    "url": url,
                    "type": "Deprecated Tag",
                    "severity": "INFO",
                    "description": f"Found deprecated tag: <{tag}>"
                })

        # 4. Check for insecure forms (non-https action)
        for form in soup.find_all('form', action=True):
            action = form['action']
            if action.startswith('http://'):
                issues.append({
                    "url": url,
                    "type": "Insecure Form",
                    "severity": "MEDIUM",
                    "description": f"Form with insecure action found: {action}"
                })

        # 5. Potential XSS bits (reflection points, inline scripts)
        # (This is still passive, just identifying points)
        if soup.find('script', string=True):
             issues.append({
                "url": url,
                "type": "Inline Script",
                "severity": "INFO",
                "description": "Inline script detected, potentially risky if not handled properly."
            })

        return issues
