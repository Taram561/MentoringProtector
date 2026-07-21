#pragma once
#include "nudge.h"

class INudgeSink {
public:
    virtual ~INudgeSink() = default;
    virtual void emit(const Nudge& nudge) = 0;
};