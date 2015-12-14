import akka.actor._

object DLListener extends App {

  class Master extends Actor {
    override def receive: Receive = {
      case a => println(s"$a received in $self")
    }
  }

  class DeadLettersListener extends Actor {
    override def receive: Actor.Receive = {
      case a => println(s"  >>> $a received in $self")
    }
  }

  // creating Master actor
  val masterActorSystem = ActorSystem("Master")
  val master = masterActorSystem.actorOf(Props[Master], "Master")
  val listener = masterActorSystem.actorOf(Props[DeadLettersListener])

  // subscribe listener to Master's DeadLetters
  masterActorSystem.eventStream.subscribe(listener, classOf[DeadLetter])
  masterActorSystem.eventStream.subscribe(listener, classOf[UnhandledMessage])

  masterActorSystem.actorSelection("/unexistingActor") ! "yo"
}