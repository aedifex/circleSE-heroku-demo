from app import app
from flask import Flask, request

import os
import unittest

class AppTestCase(unittest.TestCase):

   def test_root_text(self):
        tester = app.test_client(self)
        response = tester.get('/')
        assert 'Try it now' in response.data

if __name__ == '__main__':
    unittest.main()
