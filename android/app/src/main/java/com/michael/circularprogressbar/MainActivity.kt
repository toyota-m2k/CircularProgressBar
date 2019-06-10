package com.michael.circularprogressbar

import android.os.Bundle
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity;
import android.view.Menu
import android.view.MenuItem
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer

import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.content_main.*
import kotlin.properties.ObservableProperty

class MainActivity : AppCompatActivity() {

    val progress = MutableLiveData<Int>().apply {value = 0}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setSupportActionBar(toolbar)

        fab.setOnClickListener { view ->
            Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                .setAction("Action", null).show()
        }
        proceedButton.setOnClickListener {
            var v = progress.value ?: 0
            if(v==100) {
                v = 0
            } else {
                v += 13
                if (v > 100) {
                    v = 100
                }
            }
            progress.value = v
        }
        progress.observe(this, Observer<Int>{
            progressRing1.progress = it
            progressRing2.progress = it
            progressRing3.progress = it
        })
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        return when (item.itemId) {
            R.id.action_settings -> true
            else -> super.onOptionsItemSelected(item)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        progress.removeObservers(this)
    }
}
