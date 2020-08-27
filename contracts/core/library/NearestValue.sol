pragma solidity >= 0.5 .0 < 0.6 .0;

/*
 * @title 最接近数值记录，一般用于记录按照时间移动的数值，可以通过时间参数查询最接近值
 */
library NearestValue {

    /// 时间线和数据
    struct TimeLine {
        /// 每次记录的时间
        uint[] timeList;

        /// 每次记录的叠加数值
        mapping(uint => uint) valueMapping;
    }

    struct Data {
        /// @dev 初始化后不可修改
        uint timeInterval_final;
        mapping(address => TimeLine) timeLineMapping;
    }

    /// 追加数值
    function increase(Data storage self, address owner, uint addValue) internal returns(uint) {

        /// 时间按照间隔取整
        uint t = now / self.timeInterval_final * self.timeInterval_final;

        /// 获取当前用户对应的TimeLine
        TimeLine storage line = self.timeLineMapping[owner];

        /// 获取最后一个时间
        uint latestTime = line.timeList[line.timeList.length - 1];

        /// 若时间超过一个间隔则增加，否则直接修改
        if (latestTime == t) {
            line.valueMapping[latestTime] += addValue;
            return line.valueMapping[latestTime];
        } else {
            line.valueMapping[t] = (line.valueMapping[latestTime] + addValue);
            return line.valueMapping[t];
        }

    }

    /// 减少数值
    function decrease(Data storage self, address owner, uint subValue) internal returns(uint) {

        /// 时间按照间隔取整
        uint t = now / self.timeInterval_final * self.timeInterval_final;

        /// 获取当前用户对应的TimeLine
        TimeLine storage line = self.timeLineMapping[owner];

        /// 获取最后一个时间
        uint latestTime = line.timeList[line.timeList.length - 1];

        /// 防止减少比被减数大
        require(line.valueMapping[latestTime] >= subValue, "InsufficientQuota");

        /// 若时间超过一个间隔则增加，否则直接修改
        if (latestTime == t) {
            line.valueMapping[latestTime] -= subValue;
            return line.valueMapping[latestTime];
        } else {
            line.valueMapping[t] = (line.valueMapping[latestTime] - subValue);
            return line.valueMapping[t];
        }

    }

    /// 忽略检测直接设定值
    function forceSet(Data storage self, address owner, uint value) internal {
        /// 时间按照间隔取整
        uint t = now / self.timeInterval_final * self.timeInterval_final;

        /// 获取当前用户对应的TimeLine
        TimeLine storage line = self.timeLineMapping[owner];

        /// 获取最后一个时间
        uint latestTime = line.timeList[line.timeList.length - 1];

        /// 若时间超过一个间隔则增加，否则直接修改
        if (latestTime == t) {
            line.valueMapping[latestTime] = value;
        } else {
            line.valueMapping[t] = value;
        }
    }

    /// 最接近的左值查询（二分查找）
    function nearestLeft(Data storage self, address owner, uint time) internal view returns(uint) {

        uint[] memory s = self.timeLineMapping[owner].timeList;

        /// 无数据
        if (s.length <= 0) {
            return 0;
        }

        /// 最前面一个更小，则直接返回第一个元素
        if (time <= s[0]) {
            return self.timeLineMapping[owner].valueMapping[s[0]];
        } else {
            (uint l, ) = binarySearch(s, time);
            return self.timeLineMapping[owner].valueMapping[s[l]];
        }
    }

    /// 最接近的右值查询（二分查找）
    function nearestRight(Data storage self, address owner, uint time) internal view returns(uint) {

        uint[] memory s = self.timeLineMapping[owner].timeList;

        /// 无数据
        if (s.length <= 0) {
            return 0;
        }

        /// 插叙的数据比最后一个更大，直接返回最后一个元素
        if (time > s[s.length - 1]) {
            return self.timeLineMapping[owner].valueMapping[s[s.length - 1]];
        } else {
            (, uint r) = binarySearch(s, time);
            return self.timeLineMapping[owner].valueMapping[s[r]];
        }
    }

    /// uint数组类型的二分查找算法，返回最终游标的位置,！！源数组"s"必须为非空的数组！！否则返回的两个0的结果，直接读取会引起越界
    function binarySearch(uint[] memory s, uint key) internal pure returns(uint l, uint r) {
        if (s.length <= 0) {
            return (0, 0);
        }

        l = 0; /// 左侧游标
        r = s.length; /// 右侧游标
        for (uint c = (l + r) / 2; l != c; c = (l + r) / 2) {
            /// 若出出现直接相等的情况则说明一定是最接近的值，直接跳出即可
            if (s[c] == key) {
                l = c;
                r = c;
                break;
            }
            /// 说明需要查找的目标比当前值大，使用右半区
            if (s[c] < key) {
                l = c;
            }
            /// 使用右半区
            else {
                r = c;
            }
        }

        if (r > s.length - 1) {
            r = s.length - 1;
        }
    }
}
