package jmmplus;
import java.util.concurrent.atomic.AtomicInteger;

class BetterSorryState implements State {
	private AtomicInteger[] value;
	private byte maxval;

	private void init(byte[] v){
		value = new AtomicInteger[v.length];
		for(int i = 0; i < value.length; i++){
			value[i] = new AtomicInteger(v[i]);
		}
	}

	BetterSorryState(byte[] v) { init(v); maxval = 127; }

	BetterSorryState(byte[] v, byte m) { init(v); maxval = m; }

	public int size() { return value.length; }

	public byte[] current() { 
		byte[] a = new byte[value.length];
		for(int i = 0; i < a.length; i++){
			a[i] = (byte) value[i].get();
		}
		return a;
	}

	public boolean swap(int i, int j) {
		if (value[i].get() <= 0 || value[j].get() >= maxval) {
			return false;
		}
		value[i].getAndDecrement();
		value[j].getAndIncrement();
		return true;
	}
}

