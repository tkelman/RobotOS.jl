#API for publishing and subscribing to message topics
export Publisher, Subscriber, publish

type Publisher{MsgType<:MsgT}
    o::PyObject

    function Publisher(topic::AbstractString; kwargs...)
        @debug("Creating <$(string(MsgType))> publisher on topic: '$topic'")
        rospycls = _get_rospy_class(MsgType)
        return new(__rospy__[:Publisher](ascii(topic), rospycls; kwargs...))
    end
end
Publisher{MsgType<:MsgT}(topic::AbstractString, ::Type{MsgType}; kwargs...) =
    Publisher{MsgType}(ascii(topic); kwargs...)

function publish{MsgType<:MsgT}(p::Publisher{MsgType}, msg::MsgType)
    pycall(p.o["publish"], PyAny, convert(PyObject, msg))
end

type Subscriber{MsgType<:MsgT}
    o::PyObject
    callback

    function Subscriber(
        topic::AbstractString, cb, cb_args::Tuple=(); kwargs...
    )
        @debug("Creating <$(string(MsgType))> subscriber on topic: '$topic'")
        rospycls = _get_rospy_class(MsgType)
        jl_cb(msg::PyObject) = cb(convert(MsgType, msg), cb_args...)
        return new(
            __rospy__[:Subscriber](ascii(topic), rospycls, jl_cb; kwargs...),
            jl_cb
        )
    end
end
Subscriber{MsgType<:MsgT}(
    topic::AbstractString,
    ::Type{MsgType},
    cb,
    cb_args::Tuple=();
    kwargs...
) = Subscriber{MsgType}(ascii(topic), cb, cb_args; kwargs...)
