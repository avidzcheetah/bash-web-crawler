import asyncio
import logging
from urllib.parse import urljoin, urlparse
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class WebCrawler:
    def __init__(self, base_url, max_pages=100):
        self.base_url = base_url
        self.domain = urlparse(base_url).netloc
        self.max_pages = max_pages
        self.visited_urls = set()
        self.to_visit = [base_url]
        self.results = []

    def is_internal_url(self, url):
        parsed_url = urlparse(url)
        return parsed_url.netloc == '' or parsed_url.netloc == self.domain

    async def crawl(self):
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            context = await browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            )
            page = await context.new_page()

            while self.to_visit and len(self.visited_urls) < self.max_pages:
                current_url = self.to_visit.pop(0)

                if current_url in self.visited_urls:
                    continue

                logger.info(f"Crawling: {current_url}")
                self.visited_urls.add(current_url)

                try:
                    response = await page.goto(current_url, wait_until="networkidle", timeout=30000)
                    content = await page.content()
                    headers = await response.all_headers()
                    
                    # Store page data for analysis
                    self.results.append({
                        "url": current_url,
                        "content": content,
                        "headers": headers,
                        "status": response.status
                    })

                    # Extract links
                    soup = BeautifulSoup(content, 'html.parser')
                    for link in soup.find_all('a', href=True):
                        href = link['href']
                        full_url = urljoin(current_url, href)
                        
                        # Remove fragment
                        full_url = full_url.split('#')[0]

                        if self.is_internal_url(full_url) and full_url not in self.visited_urls and full_url not in self.to_visit:
                            self.to_visit.append(full_url)

                except Exception as e:
                    logger.error(f"Failed to crawl {current_url}: {str(e)}")
                    self.results.append({
                        "url": current_url,
                        "error": str(e)
                    })

            await browser.close()
            return self.results

if __name__ == "__main__":
    import json
    async def main():
        crawler = WebCrawler("http://testphp.vulnweb.com/")
        results = await crawler.crawl()
        print(f"Crawled {len(results)} pages.")
        # Only print first few results to avoid clutter
        # print(json.dumps(results[0], indent=2))

    asyncio.run(main())
