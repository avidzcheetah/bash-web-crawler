import asyncio
import logging
from scanner.core.crawler import WebCrawler
from scanner.modules.passive import PassiveScanner
from scanner.modules.active import ActiveScanner
from scanner.ai.analyzer import AIAnalyzer
from scanner.reporting.reporter import Reporter

logger = logging.getLogger(__name__)

class ScannerEngine:
    def __init__(self, base_url, max_pages=10):
        self.base_url = base_url
        self.crawler = WebCrawler(base_url, max_pages)
        self.passive_scanner = PassiveScanner()
        self.active_scanner = ActiveScanner()
        self.ai_analyzer = AIAnalyzer()
        self.all_issues = []

    async def run(self):
        logger.info(f"Starting crawl and scan for: {self.base_url}")
        
        # 1. Crawl
        pages = await self.crawler.crawl()
        
        # 2. Scan each page
        for page in pages:
            url = page.get("url")
            content = page.get("content")
            
            if not content:
                continue

            # Passive Scan
            headers = page.get("headers", {})
            passive_issues = self.passive_scanner.scan(url, content, headers)
            self.all_issues.extend(passive_issues)

            # Active Scan
            active_issues = await self.active_scanner.scan_url(url, content)
            
            # AI Validation for high/critical issues
            for issue in active_issues:
                if self.ai_analyzer.enabled:
                    logger.info(f"Analyzing potential {issue['type']} at {url} with AI...")
                    ai_result = await self.ai_analyzer.analyze_vulnerability(url, issue.get("snippet", ""), issue["type"])
                    if ai_result:
                         issue["ai_analysis"] = ai_result
                
                self.all_issues.append(issue)

        return self.all_issues
