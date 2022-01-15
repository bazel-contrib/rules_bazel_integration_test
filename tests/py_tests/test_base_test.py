import os
import unittest
from bazel_integration_test.py import test_base


class TestBaseTest(test_base.TestBase):

  def testVersion(self):
    self.ScratchFile('WORKSPACE')
    exit_code, stdout, stderr = self.RunBazel(['info', 'release'])
    self.AssertExitCode(exit_code, 0, stderr)


if __name__ == '__main__':
  unittest.main()
