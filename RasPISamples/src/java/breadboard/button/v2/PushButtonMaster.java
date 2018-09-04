package breadboard.button.v2;

import com.pi4j.io.gpio.GpioController;
import com.pi4j.io.gpio.GpioFactory;
import com.pi4j.io.gpio.GpioPinDigitalInput;
import com.pi4j.io.gpio.Pin;
import com.pi4j.io.gpio.PinPullResistance;
import com.pi4j.io.gpio.RaspiPin;
import com.pi4j.io.gpio.event.GpioPinListenerDigital;import pushbutton.PushButtonObserver;

import java.text.NumberFormat;
import java.util.function.Consumer;

/**
 * Implements the nuts and bolts of the push button interaction.
 * No need to worry about that in the main class.
 * From the main:
 * Invoke the initCtx method
 * Invoke the freeResources method
 *
 * TODO: Need to manage
 * - Click
 * - Double Click
 * - Long Click
 * - Two-button click (or more..., Shft, Ctrl, etc)
 *
 * Note: System.currentTimeMillis returns values like
 *   1,536,096,764,842
 *
 */
public class PushButtonMaster {
	private GpioController gpio = null;
	private GpioPinDigitalInput button = null;

	public enum ClickType {
		SINGLE_CLICK,
		DOUBLE_CLICK,
		LONG_CLICK
	};

	private Consumer<Void> onClick;
	private Consumer<Void> onDoubleClick;
	private Consumer<Void> onLongClick;

	public PushButtonMaster(Consumer<Void> onClick,
	                        Consumer<Void> onDoubleClick,
	                        Consumer<Void> onLongClick) {
		try {
			this.gpio = GpioFactory.getInstance();
		} catch (UnsatisfiedLinkError ule) {
			// Absorb. You're not on a Pi.
			System.err.println("Not on a PI? Moving on.");
		}
		this.onClick = onClick;
		this.onDoubleClick = onDoubleClick;
		this.onLongClick = onLongClick;
	}

	public void initCtx() {
		initCtx(RaspiPin.GPIO_02);
	}

	private long pushedTime = 0L;
	private long releasedTime = 0L;

	private final static long DOUBLE_CLICK_DELAY = 200L; // Less than 2 10th of sec between clicks
	private final static long LONG_CLICK_DELAY   = 500L; // Long: more than half a second

	public void initCtx(Pin buttonPin) {
		if (this.gpio != null) {
			// provision gpio pin as an output pin and turn it off
			this.button = gpio.provisionDigitalInputPin(buttonPin, PinPullResistance.PULL_DOWN);
			this.button.addListener((GpioPinListenerDigital) event -> {
				if (event.getState().isHigh()) { // Button pressed
					this.pushedTime = System.currentTimeMillis();
					System.out.println(String.format("Since last release: %s ms.", NumberFormat.getInstance().format(this.pushedTime - this.releasedTime)));
				} else if (event.getState().isLow()) { // Button released
					this.releasedTime = System.currentTimeMillis();
					System.out.println(String.format("Button was down for %s ms.", NumberFormat.getInstance().format(this.releasedTime - this.pushedTime)));
				}
				// Test the click type here, and take action
				if ((this.releasedTime - this.pushedTime) < DOUBLE_CLICK_DELAY) {
					this.onDoubleClick.accept(null);
				} else if ((this.pushedTime - this.releasedTime) > LONG_CLICK_DELAY) {
					this.onLongClick.accept(null);
				} else {
					this.onClick.accept(null);
				}
			});
		}
	}

	public boolean isPushed() {
		return this.button.isHigh();
	}

	public void freeResources() {
		if (this.gpio != null) {
			this.gpio.shutdown();
		}
//	System.exit(0);
	}
}
