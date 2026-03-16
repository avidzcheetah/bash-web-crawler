import asyncio
import argparse
import sys
import os

# Add the project root to sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from scanner.core.engine import ScannerEngine
from scanner.reporting.reporter import Reporter
from dotenv import load_dotenv

async def main():
    parser = argparse.ArgumentParser(description="Advanced AI-Powered Web Vulnerability Scanner")
    parser.add_argument("url", help="Target URL to scan")
    parser.add_argument("--max-pages", type=int, default=10, help="Maximum pages to crawl")
    parser.add_argument("--output", default="report", help="Output filename (without extension)")
    
    args = parser.parse_args()

    print(r"""
    ░▒█▀▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
    ░▒█░░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
    ░▒█▄▄▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀ v2.0
                        by 𝘈𝘷𝘪𝘥𝘻 
    """)

    if not args.url.startswith("http"):
        print("Error: URL must start with http:// or https://")
        sys.exit(1)

    load_dotenv()
    if not os.getenv("GEMINI_API_KEY"):
        print("Warning: GEMINI_API_KEY not found in .env. AI validation will be skipped.")

    engine = ScannerEngine(args.url, args.max_pages)
    issues = await engine.run()

    reporter = Reporter(f"{args.output}.json")
    reporter.generate_json(issues)
    reporter.generate_markdown(issues, f"{args.output}.md")

    print(f"\nScan complete. Found {len(issues)} potential issues.")
    print(f"Reports generated: {args.output}.json and {args.output}.md")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nScan interrupted by user.")
        sys.exit(0)
