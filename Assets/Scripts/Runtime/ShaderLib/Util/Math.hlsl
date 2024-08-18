#ifndef ARP_MATH_INCLUDE
#define ARP_MATH_INCLUDE


float Square(float n)
{
    return n*n;
}


float FastSqrt(float x)
{
    float xhalf = 0.5 * x;
    int i = asint(xhalf);
    i = 0x5f375a86 - (i >> 1);
    x = asfloat(i);
    x = x *  (1.5f - xhalf * x * x);

    return 1/x;
}

float DistanceSquared(float pA, float pB)
{
    return dot(pA - pB, pA - pB);
}

#endif