#include <gtest/gtest.h>
#include <cplamp/ai.h>

TEST(CPLampDummyTest,DummyDoesNotCrash){
    cplamp::dummy();
    EXPECT_TRUE(true);
}