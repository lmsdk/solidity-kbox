const slog = require('single-line-log').stdout;

const OneDay = 86400;

// var styles = {
//     'bold'          : ['\x1B[1m',  '\x1B[22m'],
//     'italic'        : ['\x1B[3m',  '\x1B[23m'],
//     'underline'     : ['\x1B[4m',  '\x1B[24m'],
//     'inverse'       : ['\x1B[7m',  '\x1B[27m'],
//     'strikethrough' : ['\x1B[9m',  '\x1B[29m'],
//     'white'         : ['\x1B[37m', '\x1B[39m'],
//     'grey'          : ['\x1B[90m', '\x1B[39m'],
//     'black'         : ['\x1B[30m', '\x1B[39m'],
//     'blue'          : ['\x1B[34m', '\x1B[39m'],
//     'cyan'          : ['\x1B[36m', '\x1B[39m'],
//     'green'         : ['\x1B[32m', '\x1B[39m'],
//     'magenta'       : ['\x1B[35m', '\x1B[39m'],
//     'red'           : ['\x1B[31m', '\x1B[39m'],
//     'yellow'        : ['\x1B[33m', '\x1B[39m'],
//     'whiteBG'       : ['\x1B[47m', '\x1B[49m'],
//     'greyBG'        : ['\x1B[49;5;8m', '\x1B[49m'],
//     'blackBG'       : ['\x1B[40m', '\x1B[49m'],
//     'blueBG'        : ['\x1B[44m', '\x1B[49m'],
//     'cyanBG'        : ['\x1B[46m', '\x1B[49m'],
//     'greenBG'       : ['\x1B[42m', '\x1B[49m'],
//     'magentaBG'     : ['\x1B[45m', '\x1B[49m'],
//     'redBG'         : ['\x1B[41m', '\x1B[49m'],
//     'yellowBG'      : ['\x1B[43m', '\x1B[49m']
// }

async function EVMDelaySec(s) {

    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [s],
        id: Math.round(new Date() / 1000),
    }, ()=> {

    });

    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_mine",
        params: [],
        id: Math.round(new Date() / 1000),
    }, ()=> {

    });
}

async function EVMDelayDay(d) {

    var s = d * OneDay;

    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [s],
        id: Math.round(new Date() / 1000),
    }, ()=> {

    });

    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_mine",
        params: [],
        id: Math.round(new Date() / 1000),
    }, ()=> {

    });
}

var snapshotStack = new Array();

async function PushSnapShot() {
    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_snapshot",
        params: [],
        id: Math.round(new Date() / 1000),
    }, (err, snapshotID)=> {
        snapshotStack.push(snapshotID.result);
    });
}

async function PopSnapShot() {
    var snid = snapshotStack.pop();
    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_revert",
        params: [snid],
        id: Math.round(new Date() / 1000),
    }, () => {

    });
}

async function PopSnapShotRoot() {
    var rootSNID = snapshotStack[0];
    snapshotStack = new Array();
    await web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_revert",
        params: [rootSNID],
        id: Math.round(new Date() / 1000),
    }, () => {

    });
}

var caseCount = 0;

async function IsRevert(p, msg) {

    var r = false;

    await p.catch((c)=>{
        r = true;
    })

    if (msg) {
        assert.equal(true, r, "🙅 " + msg);
    } else {
        assert.equal(true, r, "🙅 Not Revert");
    }

    console.log('\t\x1B[32m✓\x1B[39m \x1B[90mcase %d: %s\x1B[39m', ++caseCount, msg);
}


function AssertEqual(a,b,m) {
    assert.equal(a, b, "🙅 " + m)
    console.log('\t\x1B[32m✓\x1B[39m \x1B[90mcase %d: %s\x1B[39m', ++caseCount, m);
}

var logstack = new Array();
var errorstack = new Array();

function Log(m) {
    logstack.push(m)
}

function Err(m) {
    errorstack.push(m)
}

function PrintLogStack() {

    for (var i = 0; i < logstack.length; i++) {
        console.log('\t\x1B[90m%s\x1B[39m', logstack[i]);
    }

    console.log('\n');

    for (var i = 0; i < errorstack.length; i++) {
        console.log('\t\x1B[31m🙅🙅 %s 🙅🙅\x1B[39m', errorstack[i]);
    }

    logstack = new Array();
    errorstack = new Array();
}


// 封装的 ProgressBar 工具
function ProgressBar(description, taskSum) {

    // 两个基本参数(属性)
    this.description = description || 'Progress';    // 命令行开头的文字信息
    this.length = 25;           // 进度条的长度(单位：字符)，默认设为 25
    this.total = taskSum;
    this.completed = 0;

    // 刷新进度条图案、文字的方法
    this.render = function () {
        var percent = (this.completed / this.total).toFixed(4);  // 计算进度(子任务的 完成数 除以 总数)
        var cell_num = Math.floor(percent * this.length);        // 计算需要多少个 █ 符号来拼凑图案

        // 拼接黑色条
        var cell = '';
        for (var i = 0; i < cell_num; i++) {
            cell += '█';
        }

        // 拼接灰色条
        var empty = '';
        for (var i=0; i < this.length - cell_num; i++) {
            empty += '░';
        }

        // 拼接最终文本
        var cmdText = (100*percent).toFixed(2) + '% ' + cell + empty + ' ' + this.description;

        // 在单行输出文本
        slog("\t⏳ \x1B[90m" + cmdText + "\x1B[39m");
    };

    this.done = function() {
        slog("");
    }

    this.completeOnce = function () {
        this.completed++;
        this.render();
        if ( this.completed >= this.total ) {
            slog("");
        }
    }
}

exports.deployed = KDeployed
exports.mustRevert = IsRevert
exports.pushSnapShot = PushSnapShot
exports.popSnapShot = PopSnapShot
exports.popSnapShotRoot = PopSnapShotRoot
exports.evmDelaySec = EVMDelaySec
exports.evmDelayDay = EVMDelayDay
exports.equal = AssertEqual
exports.log = Log
exports.err = Err
exports.printLogs = PrintLogStack
exports.ProgressBar = ProgressBar
