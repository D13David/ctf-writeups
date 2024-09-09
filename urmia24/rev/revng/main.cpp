#include <string>
#include <iostream>
#include <fstream>
#include <vector>

struct rng_t
{
    uint32_t seed;
    uint32_t mul;
    uint32_t add;
    uint32_t mask;
};

void read_byte_from_file(std::vector<uint8_t>& fileContent, const std::string& fileName);
void write_content_to_file(const std::string& fileName, std::vector<uint8_t> fileContent, std::time_t timeStamp);
uint64_t next_value_in_range(rng_t& rng, int32_t start, int32_t end);
void initialize_rng(rng_t& rng, uint32_t seed);
void generate_number_vector(std::vector<int>& result, int32_t start, int32_t end, std::time_t currentTime);
void encrypt_data(std::vector<uint8_t>& output, const std::vector<int>& key, const std::vector<uint8_t>& sourceData);

int main(int argc, char** argv)
{
    if (argc == 3)
    {
        std::time_t currentTime = std::time(nullptr);
        std::string sourceFileName = argv[1];
        std::string destFileName = argv[2];

        std::vector<uint8_t> sourceBuffer;
        read_byte_from_file(sourceBuffer, sourceFileName);

        std::vector<int> numbers;
        generate_number_vector(numbers, 0, sourceBuffer.size(), currentTime);

        std::vector<uint8_t> destBuffer;
        encrypt_data(destBuffer, numbers, sourceBuffer);

        write_content_to_file(destFileName, destBuffer, currentTime);
    }
    else
    {
        std::cerr << "Usage: " << *argv << " <src> <dst>" << std::endl;
    }
}

void initialize_rng(rng_t& rng, uint32_t seed)
{
    rng.seed = seed;
    rng.mul = 0x19660d;
    rng.add = 0x3c6ef35f;
    rng.mask = 0xffffffff;
}

uint64_t next_value(rng_t& rng)
{
    rng.seed = (rng.mul * rng.seed + rng.add) & rng.mask;
    return rng.seed;
}

uint64_t next_value_in_range(rng_t& rng, int32_t start, int32_t end)
{
    return start + (next_value(rng) % (end - start));
}

uint64_t swap_bits(int32_t value, char bits)
{
    return ((uint64_t)((value << (8 - bits)) | (value >> bits)));
}

void generate_number_vector(std::vector<int>& result, int32_t start, int32_t end, std::time_t currentTime)
{
    rng_t rng;
    initialize_rng(rng, currentTime);

    for (int32_t i = start; i < end; ++i) {
        result.push_back(i);
    }

    for (int32_t i = 0; i < result.size(); ++i)
    {
        int& index = result.at(next_value_in_range(rng, i, result.size()));
        std::swap(result.at(i), index);
    }
}

void encrypt_data(std::vector<uint8_t>& output, const std::vector<int>& key, const std::vector<uint8_t>& sourceData)
{
    for (int32_t i = 0; i < sourceData.size(); ++i)
    {
        uint8_t value = swap_bits(sourceData[i] ^ key[i % key.size()], 5);
        output.push_back(value);
    }
}

void read_byte_from_file(std::vector<uint8_t>& fileContent, const std::string& fileName)
{
    std::ifstream file(fileName);

    if (!file.is_open())
    {
        std::cerr << "Error opening file: " << std::endl;
        std::exit(1);
    }

    while (true)
    {
        char c;
        if (!file.read(&c, 1)) {
            break;
        }

        fileContent.push_back(c);
    }

    file.close();
}

void write_content_to_file(const std::string& fileName, std::vector<uint8_t> fileContent, std::time_t timeStamp)
{
    std::ofstream file(fileName, std::ios::out | std::ios::binary);

    if (!file.is_open())
    {
        std::cerr << "Error opening file: " << std::endl;
        std::exit(1);
    }

    for (auto it : fileContent) {
        file.write((const char*)&it, 1);
    }

    file.write((const char*)&timeStamp, 4);
}