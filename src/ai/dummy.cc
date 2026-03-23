#include <cplamp/ai.h>
#include <Eigen/Dense>
#include <fmt/core.h>
#include <spdlog/spdlog.h>



namespace cplamp
{
    void dummy()
    {
         Eigen::Vector3f v(1.0f, 2.0f, 3.0f);
        float sum = v.sum();

        auto message = fmt::format("Vector sum is: {}", sum);   

        spdlog::info("{}", message);
    }
}