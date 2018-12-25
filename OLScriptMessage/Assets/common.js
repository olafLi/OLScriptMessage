Object.assign(window.ios , {})

var JKEventHandler = {
    bindCallBack: function (fn, func_name) {
        var message = {};
        message["func_name"] = func_name

        for (var index = 0; index < fn.arguments.length; index++) {
            var obj = fn.arguments[index]
            if (typeof obj == "function") { //函数 回调函数
                var callback_func_name = obj.name.length > 0 ? obj.name :
                    func_name + "_callback_" + index + "_" + Date.parse(
                        Date())
                if (!Event._listeners[callback_func_name]) {
                    Event.addEvent(callback_func_name, function (data) {
                        obj(data);
                    });
                }
                if (typeof callback_func_name === "string") {
                    message["callback"] = callback_func_name
                }
            } else {
                if (typeof message["params"] == "undefined") {
                    message["params"] = {};
                }

                if (typeof obj === "object") {
                    for (var v in obj) {
                        message["params"][v] = obj[v];
                    }
                }
            }
        }
        return message
    },
    callBack: function (callBackName, data) {
        Event.fireEvent(callBackName, data);
    },
    removeAllCallBacks: function (data) {
        Event._listeners = {};
    }
};

var Event = {
    _listeners: {},

    addEvent: function (type, fn) {
        if (typeof this._listeners[type] === "undefined") {
            this._listeners[type] = [];
        }
        if (typeof fn === "function") {
            this._listeners[type].push(fn);
        }

        return this;
    },

    fireEvent: function (type, param) {
        var arrayEvent = this._listeners[type];
        if (arrayEvent instanceof Array) {
            for (var i = 0, length = arrayEvent.length; i < length; i +=
                1) {
                if (typeof arrayEvent[i] === "function") {
                    arrayEvent[i](param);
                }
            }
        }
        return this;
    },

    removeEvent: function (type, fn) {
        var arrayEvent = this._listeners[type];
        if (typeof type === "string" && arrayEvent instanceof Array) {
            if (typeof fn === "function") {
                for (var i = 0, length = arrayEvent.length; i < length; i +=
                    1) {
                    if (arrayEvent[i] === fn) {
                        this._listeners[type].splice(i, 1);
                        break;
                    }
                }
            } else {
                delete this._listeners[type];
            }
        }
        return this;
    }
};
