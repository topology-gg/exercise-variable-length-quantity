# conftest.py

def pytest_addoption(parser):
    parser.addoption("--name", action="store", default="template")
