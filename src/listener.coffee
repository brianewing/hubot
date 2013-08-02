{inspect} = require 'util'
domain = require 'domain'

{TextMessage} = require './message'

class Listener
  # Listeners receive every message from the chat source and decide if they
  # want to act on it.
  #
  # robot    - A Robot instance.
  # matcher  - A Function that determines if this listener should trigger the
  #            callback.
  # callback - A Function that is triggered if the incoming message matches.
  constructor: (@robot, @matcher, @callback) ->
    @domain = domain.create()
    @domain.on 'error', (error) =>
      @robot.logger.error "Error while listener handled message: #{error}\n#{error.stack}"

  # Public: Determines if the listener likes the content of the message. If
  # so, a Response built from the given Message is passed to the Listener
  # callback.
  #
  # message - A Message instance.
  #
  # Returns a boolean of whether the matcher matched.
  call: (message) ->
    if match = @matcher message
      @robot.logger.debug \
        "Message '#{message}' matched regex /#{inspect @regex}/" if @regex

      @domain.run => @callback(new @robot.Response(@robot, message, match))
      true
    else
      false

class TextListener extends Listener
  # TextListeners receive every message from the chat source and decide if they
  # want to act on it.
  #
  # robot    - A Robot instance.
  # regex    - A Regex that determines if this listener should trigger the
  #            callback.
  # callback - A Function that is triggered if the incoming message matches.
  constructor: (@robot, @regex, @callback) ->
    super

    @matcher = (message) =>
      if message instanceof TextMessage
        message.match @regex

module.exports = {
  Listener
  TextListener
}
