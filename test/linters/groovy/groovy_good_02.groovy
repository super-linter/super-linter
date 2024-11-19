import groovy.text.*
import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

@Library('somelib')
import com.mycorp.pipeline.somelib.Helper

int useSomeLib(Helper helper) {
    helper.prepare()
    return helper.count()
}

echo useSomeLib(new Helper('some text'))
