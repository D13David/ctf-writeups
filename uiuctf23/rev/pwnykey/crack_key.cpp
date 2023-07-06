#include <algorithm>
#include <random>
#include <iterator>
#include <vector>
#include <numeric>

const char* part1()
{
	return "YANXA"; // this is trivially read from disassembly
}

#define PART1_NUM_ELEMENTS 10
#define PART2_NUM_ELEMENTS 5

const char* part2()
{
    static char resultStr[12]{};

    std::random_device rd;
    std::mt19937 eng(rd());
    std::vector<int> buffer{};
    std::vector<int> values(31);

    std::iota(values.begin(), values.end(), 1);

    while (true)
    {
        buffer.clear();
        std::sample(values.begin(), values.end(), std::back_inserter(buffer), 10, eng);

        uint64_t sum = 0, prod = 1;
        for (int i = 0; i < PART1_NUM_ELEMENTS; ++i)
        {
            sum += buffer[i];
            prod *= buffer[i];
        }

        if (sum == 134 && prod == 12534912000)
        {
            int i = 0;
            for (i = 0; i < PART1_NUM_ELEMENTS/2; ++i)
            {
                resultStr[i] = "0123456789ABCDFGHJKLMNPQRSTUWXYZ"[buffer[i]];
            }
            resultStr[i] = '-';
            for (; i < PART1_NUM_ELEMENTS; ++i)
            {
                resultStr[i + 1] = "0123456789ABCDFGHJKLMNPQRSTUWXYZ"[buffer[i]];
            }
            break;
        }
    }

    return resultStr;
}

int xorwow(int ring[5], int& count, int& front)
{
    int back = (front + 1) % 5, value = ring[front];
    value = (value ^ ((value >> 2) & 0xFFFFFFFF));
    value = (value ^ ((value << 1) & 0xFFFFFFFF));
    value = (value ^ ((ring[back] ^ (ring[back] << 4)) & 0xFFFFFFFF));
    count = ((count + 13371337) & 0xFFFFFFFF);
    ring[front] = value;

    front = (front + 4) % 5;

    return value + count;
}

const char* part3()
{
    static char result[6]{};
    int buffer[PART2_NUM_ELEMENTS]{};
    while (true)
    {
        int carry = 1;
        for (int j = PART2_NUM_ELEMENTS - 1; j >= 0; j--)
        {
            int state[PART2_NUM_ELEMENTS];
            for (int i = 0; i < PART2_NUM_ELEMENTS; ++i) {
                state[i] = buffer[i];
            }

            int counter = 1337, front = 4;
            for (int i = 0; i < 420; ++i)
            {
                xorwow(state, counter, front);
            }

            int v1 = xorwow(state, counter, front);
            int v2 = xorwow(state, counter, front);
            int v3 = xorwow(state, counter, front);

            if ((unsigned int)v1 == 2897974129 && v2 == -549922559 && v3 == -387684011)
            {
                for (int i = PART2_NUM_ELEMENTS-1; i >= 0; --i)
                {
                    result[i] = "0123456789ABCDFGHJKLMNPQRSTUWXYZ"[buffer[i]];
                }
                goto win;
            }

            buffer[j] += carry;
            carry = buffer[j] / 32;
            buffer[j] %= 32;
        }
    }
win:
    return result;
}

int main()
{
	//printf("%s-", part1());
	//printf("%s-", part2());
    printf("%s", part3());
}