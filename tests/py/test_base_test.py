import os
import unittest
# from bazel_integration_test import test_base
# from py import test_base
import test_base


class TestBaseTest(test_base.TestBase):

  def testVersion(self):
    self.ScratchFile('WORKSPACE')
    exit_code, stdout, stderr = self.RunBazel(['info', 'release'])
    self.AssertExitCode(exit_code, 0, stderr)
    self.assertTrue(("release " + self.bazelVersion) in stdout[0])


if __name__ == '__main__':
  unittest.main()
